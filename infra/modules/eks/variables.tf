variable "name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "node_role_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "access_entries" {
  description = "EKS access entries to grant IAM principals cluster access"
  type        = any
  default     = {}
}
