provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  name = var.cluster_name
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ---------------- VPC ----------------
module "vpc" {
  source       = "./modules/vpc"
  name         = local.name
  vpc_cidr     = "10.0.0.0/16"
  azs          = local.azs
  public_bits  = 8
  private_bits = 8
}

# ----------- GitHub OIDC -----------
module "github_oidc" {
  source = "./modules/github_oidc"

  cluster_name          = var.cluster_name
  repo_full_name        = "samiiraqi/flask-app-k8s"   # <--- must match your GitHub owner/repo
  branch_ref            = "refs/heads/main"
  use_existing_provider = false                        # <--- ensure provider is CREATED
  existing_provider_arn = null
}



# ---------------- EKS ----------------
module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  instance_types = var.instance_types
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size

  # local admin
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::156041402173:user/sami"
      username = "sami"
      groups   = ["system:masters"]
    }
  ]

  # GitHub Actions role can kubectl
  aws_auth_roles = [
    {
      rolearn  = module.github_oidc.role_arn
      username = "github-actions"
      groups   = ["system:masters"]
    }
  ]
}

# ---------------- ECR ----------------
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.cluster_name
}

# --------------- Storage ---------------
module "storage" {
  source              = "./modules/storage"
  bucket_name_prefix  = var.s3_bucket_name
  random_suffix       = random_string.suffix.result
  dynamodb_table_name = var.dynamodb_table_name
}

# ======================================================================
# KUBERNETES PROVIDER (fixes: tries to reach http://localhost for aws-auth)
# ======================================================================

# Read cluster connection details after the cluster exists
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

# Use token-based auth to talk to the cluster from Terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
