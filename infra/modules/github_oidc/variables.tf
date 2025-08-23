variable "role_name" {
  description = "Name of the IAM role to create for GitHub Actions"
  type        = string
}

variable "subjects" {
  description = "List of allowed sub claims: repo:OWNER/REPO:ref:refs/heads/BRANCH"
  type        = list(string)
}

variable "ecr_repo_arn" {
  description = "ARN of the ECR repo the CI needs to push to"
  type        = string
}

variable "allow_ecr_actions" {
  description = "ECR actions to allow on the repository"
  type        = list(string)
  
}

variable "allow_eks_actions" {
  description = "EKS actions to allow (DescribeCluster needed)"
  type        = list(string)
  
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
