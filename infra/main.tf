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

# ---------- VPC ----------
module "vpc" {
  source       = "./modules/vpc"
  name         = local.name
  vpc_cidr     = "10.0.0.0/16"
  azs          = local.azs
  public_bits  = 8
  private_bits = 8
}

# ---------- GitHub OIDC ----------
module "github_oidc" {
  source = "./modules/github_oidc"

  cluster_name          = var.cluster_name
  repo_full_name        = "samiiraqi/flask-app-k8s" # <-- EXACT org/repo
  use_existing_provider = false
  existing_provider_arn = null
}

# ---------- EKS ----------
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
}

# ---------- ECR ----------
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.cluster_name
}

# ---------- Storage (optional) ----------
module "storage" {
  source              = "./modules/storage"
  bucket_name_prefix  = var.s3_bucket_name
  random_suffix       = random_string.suffix.result
  dynamodb_table_name = var.dynamodb_table_name
}
