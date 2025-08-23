provider "aws" {
  region = var.aws_region
  default_tags { tags = var.tags }
}

data "aws_caller_identity" "current" {}

locals {
  name     = var.name_prefix
  subjects = [for b in var.github_branches : "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${b}"]

  computed_app_bucket   = "${var.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  final_app_bucket_name = var.app_bucket_name != "" ? var.app_bucket_name : local.computed_app_bucket
}

# --- VPC ---
module "vpc" {
  source   = "./modules/vpc"
  name     = local.name
  cidr     = var.vpc_cidr
  az_count = var.az_count
  tags     = var.tags
}

# --- ECR (NO KMS) ---
module "ecr" {
  source          = "./modules/ecr"
  repository_name = local.name
  
  tags            = var.tags
}

# --- GitHub OIDC role ---
module "github_oidc" {
  source       = "./modules/github_oidc"
  role_name    = "devsecops-github-actions-role"
  subjects     = local.subjects
  ecr_repo_arn = module.ecr.repository_arn
  tags         = var.tags

  allow_ecr_actions = [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
    "ecr:PutImage", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload",
    "ecr:DescribeRepositories", "ecr:ListImages", "ecr:BatchDeleteImage"
  ]
  allow_eks_actions = ["eks:DescribeCluster"]
}

# --- EKS (NO KMS) ---
module "eks" {
  source                               = "./modules/eks"
  name                                 = local.name
  kubernetes_version                   = var.kubernetes_version
  vpc_id                               = module.vpc.vpc_id
  private_subnet_ids                   = module.vpc.private_subnet_ids
  public_subnet_ids                    = module.vpc.public_subnet_ids
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  access_entries = {
    github_admin = {
      principal_arn = module.github_oidc.role_arn
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
  }

  # Keep ONLY access_entries (do NOT also use map_roles to avoid duplicates)
  node_role_name = "devsecops-eks-cluster-node-role"
  tags           = var.tags
}

# --- S3 storage (NO KMS) ---
module "storage" {
  source        = "./modules/storage"
  bucket_name   = local.final_app_bucket_name
  create_kms    = false
  force_destroy = true
  tags          = var.tags
}
