variable "use_existing_provider" {
  type    = bool
  default = false
}

variable "existing_provider_arn" {
  type    = string
  default = null
}

variable "cluster_name" {
  type = string
}

variable "repo_full_name" {
  type        = string
  description = "GitHub repo in org/repo format, e.g., samiiraqi/flask-app-k8s"
}
