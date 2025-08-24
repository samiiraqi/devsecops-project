provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  name     = var.name_prefix
  subjects = [
    for b in var.github_branches :
    "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${b}"
  ]
}

# --- VPC ---
module "vpc" {
  source   = "./modules/vpc"
  name     = local.name
  cidr     = var.vpc_cidr
  az_count = var.az_count
  tags     = var.tags
}

# --- ECR (no KMS) ---
module "ecr" {
  source          = "./modules/ecr"
  repository_name = local.name
  tags            = var.tags
}

# --- GitHub OIDC role (uses existing OIDC provider in the account) ---
module "github_oidc" {
  source       = "./modules/github_oidc"
  role_name    = "devsecops-github-actions-role"
  subjects     = local.subjects
  ecr_repo_arn = module.ecr.repository_arn
  tags         = var.tags

  allow_ecr_actions = [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload",
    "ecr:DescribeRepositories",
    "ecr:ListImages",
    "ecr:BatchDeleteImage"
  ]

  allow_eks_actions = [
    "eks:DescribeCluster"
  ]
}

# --- EKS ---
module "eks" {
  source                 = "./modules/eks"
  name                   = local.name
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = module.vpc.vpc_id

  # Control-plane ENIs across ALL subnets (public + private is okay)
  cluster_subnet_ids     = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)

  # WORKER NODES → PUBLIC subnets so they have Internet egress without NAT
  node_subnet_ids        = module.vpc.public_subnet_ids

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # 2 nodes, 2 replicas target
  min_size     = 2
  desired_size = 2
  max_size     = 3
  instance_types = ["t3.medium"]

  tags = var.tags
}


# --- S3 storage (no KMS) ---
module "storage" {
  source        = "./modules/storage"
  bucket_name   = var.app_bucket_name
  create_kms    = false
  force_destroy = false
  tags          = var.tags
}
