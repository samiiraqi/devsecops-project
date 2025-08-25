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

# --- ECR ---
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

# --- EKS (public subnets for both control plane ENIs & nodes) ---
module "eks" {
  source                               = "./modules/eks"
  name                                 = local.name
  kubernetes_version                   = var.kubernetes_version
  vpc_id                               = module.vpc.vpc_id
  cluster_subnet_ids                   = module.vpc.public_subnet_ids
  node_subnet_ids                      = module.vpc.public_subnet_ids
  instance_types                       = var.instance_types
  min_size                             = 2
  desired_size                         = 2
  max_size                             = 3
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  tags                                 = var.tags

  # >>> NEW: grant cluster admin to GH Actions, Terraform role, and user 'sami'
  access_entries = {
    github_admin = {
      principal_arn = "arn:aws:iam::156041402173:role/devsecops-github-actions-role"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
    terraform_admin = {
      principal_arn = "arn:aws:iam::156041402173:role/devsecops-terraform-role"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
    sami_admin = {
      principal_arn = "arn:aws:iam::156041402173:user/sami"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
}

# --- S3 storage ---
module "storage" {
  source        = "./modules/storage"
  bucket_name   = "${local.name}-app-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  create_kms    = false
  force_destroy = false
  tags          = var.tags
}
