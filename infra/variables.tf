variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Base name for resources"
  type        = string
  default     = "devsecops"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to access the EKS public endpoint"
  type        = list(string)
  default     = [
    "0.0.0.0/0"
  ]
}

variable "app_bucket_name" {
  description = "S3 bucket for app/data (also used as TF backend)"
  type        = string
  default     = "devsecops-156041402173-us-east-1"
}

variable "github_org" {
  description = "GitHub org (owner)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without owner)"
  type        = string
}

variable "github_branches" {
  description = "Branches allowed to assume OIDC roles"
  type        = list(string)
  default     = [
    "main"
  ]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Project = "devsecops"
    Managed = "terraform"
  }
}
