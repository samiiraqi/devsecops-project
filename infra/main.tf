provider "aws" { region = var.aws_region }

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.subnet_ids
  instance_types      = var.instance_types
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size
}

module "storage" {
  source               = "./modules/storage"
  s3_bucket_name       = "${var.s3_bucket_name}-${random_string.suffix.result}"
  dynamodb_table_name  = var.dynamodb_table_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.cluster_name
}
