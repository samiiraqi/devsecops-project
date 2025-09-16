variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "devsecops-project"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "tags" {
  type = map(string)
  default = {
    Project = "devsecops-project"
    Managed = "terraform"
  }
}

variable "github_org" {
  type = string
  default = "samiiraqi"
}

variable "github_repo" {
  type = string
  default = "devsecops-project"
}

variable "github_branches" {
  type    = list(string)
  default = ["main", "develop", "feature/*"]
}



