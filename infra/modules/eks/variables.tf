variable "name" { type = string }
variable "kubernetes_version" { type = string }
variable "vpc_id" { type = string }

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Map of access entries (principal_arn + policy associations)
variable "access_entries" {
  type = map(object({
    principal_arn = string
    policy_associations = map(object({
      policy_arn = string
      access_scope = object({
        type       = string # "cluster" or "namespace"
        namespaces = optional(list(string))
      })
    }))
  }))
  default = {}
}

variable "node_role_name" {
  type        = string
  description = "Name for worker node role"
  default     = "eks-node-role"
}

variable "tags" {
  type    = map(string)
  default = {}
}
