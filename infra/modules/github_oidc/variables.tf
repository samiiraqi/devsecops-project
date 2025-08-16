variable "cluster_name"          { type = string }
variable "repo_full_name"        { type = string }  # "owner/repo"
variable "branch_ref"            { type = string }  # e.g., "refs/heads/main"

# IMPORTANT: default to false so Terraform CREATES the provider
variable "use_existing_provider" {
  type    = bool
  default = false
}

# Leave empty/null when use_existing_provider = false
variable "existing_provider_arn" {
  type    = string
  default = ""
}
