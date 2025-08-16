variable "cluster_name" { type = string }
variable "repo_full_name" { type = string } # "owner/repo"
variable "branch_ref" { type = string }     # e.g., "refs/heads/main"
variable "use_existing_provider" {
  type    = bool
  default = true
}
variable "existing_provider_arn" {
  type    = string
  default = null
}
