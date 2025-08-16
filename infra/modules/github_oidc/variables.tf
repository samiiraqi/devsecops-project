variable "cluster_name" {
  type = string
}

variable "repo_full_name" {
  type = string
}

variable "branch_ref" {
  type = string
}

variable "use_existing_provider" {
  type    = bool
  default = true
}

variable "existing_provider_arn" {
  type    = string
  default = ""
}