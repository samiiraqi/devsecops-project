variable "repository_name" {
  type = string
}

variable "enable_lifecycle_policy" {
  type    = bool
  default = true
}

variable "lifecycle_policy" {
  type        = string
  description = "ECR lifecycle policy JSON"
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

variable "tags" {
  type    = map(string)
  default = {}
}
