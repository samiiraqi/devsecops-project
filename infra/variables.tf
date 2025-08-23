############################
# Global / project settings
############################

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Base name/prefix for all resources"
  type        = string
  default     = "devsecops"
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    Project = "devsecops"
    Managed = "terraform"
  }
}

############################
# Networking (VPC)
############################

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs/subnets to create"
  type        = number
  default     = 2
}

############################
# GitHub OIDC / CI
############################

variable "github_org" {
  description = "GitHub org (owner)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)"
  type        = string
}

variable "github_branches" {
  description = "Branches allowed to assume the role (e.g., [\"main\"])"
  type        = list(string)
  default     = ["main"]
}

############################
# EKS
############################

variable "kubernetes_version" {
  description = "EKS Kubernetes version (e.g., 1.29)"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allowed CIDRs to reach EKS public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################
# App storage (S3)
############################

variable "app_bucket_name" {
  description = <<EOT
Optional explicit S3 bucket name. If left empty, a unique, deterministic
name will be generated as: <name_prefix>-<account_id>-<region>
EOT
  type        = string
  default     = ""
}
