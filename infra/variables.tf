variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "devsecops"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "flask-app-k8s"
    ManagedBy = "terraform"
    Env       = "prod"
  }
}

# GitHub OIDC mapping
variable "github_org" {
  type    = string
  default = "samiiraqi"
}

variable "github_repo" {
  type    = string
  default = "flask-app-k8s"
}

variable "github_branches" {
  type    = list(string)
  default = ["main"]
}

# Networking
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

# EKS
variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Storage
variable "app_bucket_name" {
  type    = string
  default = "flask-app-k8s-156041402173-app"
}
