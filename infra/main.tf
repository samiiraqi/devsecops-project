provider "aws" {
  region = var.aws_region
  default_tags { tags = var.tags }
}

data "aws_caller_identity" "current" {}

locals {
  name     = var.name_prefix
  subjects = [for b in var.github_branches : "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${b}"]
}

# --- VPC (no NAT) ---
module "vpc" {
  source   = "./modules/vpc"
  name     = local.name
  cidr     = var.vpc_cidr
  az_count = var.az_count
  tags     = var.tags
}

# --- ECR (explicit lifecycle_policy to satisfy module requirement) ---
module "ecr" {
  source                  = "./modules/ecr"
  repository_name         = local.name
  enable_lifecycle_policy = true
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection    = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
  tags = var.tags
}

# --- GitHub OIDC role ---
module "github_oidc" {
  source       = "./modules/github_oidc"
  role_name    = "devsecops-github-actions-role"
  subjects     = local.subjects
  ecr_repo_arn = module.ecr.repository_arn
  tags         = var.tags

  allow_ecr_actions = [
    "ecr:GetAuthorizationToken","ecr:BatchCheckLayerAvailability","ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage","ecr:PutImage","ecr:InitiateLayerUpload","ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload","ecr:DescribeRepositories","ecr:ListImages","ecr:BatchDeleteImage"
  ]
  allow_eks_actions = ["eks:DescribeCluster"]
}

# --- EKS (cluster + managed node group in PUBLIC subnets) ---
module "eks" {
  source                             = "./modules/eks"
  name                               = local.name
  kubernetes_version                 = var.kubernetes_version
  vpc_id                             = module.vpc.vpc_id
  cluster_subnet_ids                 = module.vpc.public_subnet_ids
  node_subnet_ids                    = module.vpc.public_subnet_ids
  instance_types                     = var.instance_types
  min_size                           = 2
  desired_size                       = 2
  max_size                           = 3
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  tags                               = var.tags
}

# --- S3 storage (backend/app bucket) ---
module "storage" {
  source        = "./modules/storage"
  bucket_name   = "${local.name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  create_kms    = false
  force_destroy = false
  tags          = var.tags
}
