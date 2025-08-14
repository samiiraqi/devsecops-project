data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, var.subnet_count) : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, var.subnet_count) : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enable_irsa = true

  eks_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-nodes"
      
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      remote_access = {
        ec2_ssh_key = var.ec2_ssh_key
      }
    }
  }

  # CHANGE THIS TO TRUE
  manage_aws_auth_configmap = true

  # ADD YOUR AWS USER (replace with your actual user ARN)
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::156041402173:user/sami"  # ← Replace with your username
      username = "sami"  # ← Replace with your username
      groups   = ["system:masters"]
    }
  ]

  # ADD CI/CD ROLES (add these when you set up CI/CD)
  aws_auth_roles = [
    # Example GitHub Actions role (add when you create it)
    # {
    #   rolearn  = "arn:aws:iam::156041402173:role/GitHubActionsRole"
    #   username = "github-actions"
    #   groups   = ["system:masters"]
    # }
    
    # Example CI/CD role (add when you create it)
    # {
    #   rolearn  = "arn:aws:iam::156041402173:role/CICDRole"
    #   username = "ci-cd"
    #   groups   = ["system:masters"]
    # }
  ]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-load-balancer-controller = {
      most_recent = true
    }
  }

  tags = {
    Name = var.cluster_name
  }
}
resource "aws_ecr_repository" "app_ecr" {
  name                 = "${var.cluster_name}-ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.cluster_name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "app_ecr_policy" {
  repository = aws_ecr_repository.app_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "flask-app-bucket-${random_string.suffix.result}"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = {
    Name = "flask-app-bucket-${random_string.suffix.result}"
  }
}

resource "aws_dynamodb_table" "app_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}