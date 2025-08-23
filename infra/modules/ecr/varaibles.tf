variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the repository"
  type        = map(string)
  default     = {}
}

# Keep for compatibility with root module; not used
variable "create_kms_key" {
  description = "Not used (we do not manage encryption here)"
  type        = bool
  default     = false
}

# We will NOT manage image_tag_mutability unless explicitly asked
variable "manage_mutability" {
  description = "If true, manage image_tag_mutability; if false, leave as-is"
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "Desired mutability if manage_mutability = true (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
}

# Lifecycle policy
variable "enable_lifecycle_policy" {
  description = "Attach a lifecycle policy to ECR"
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON to attach when enabled"
  type        = string
  default     = <<JSON
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": { "type": "expire" }
    }
  ]
}
JSON
}
