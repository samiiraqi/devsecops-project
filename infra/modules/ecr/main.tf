resource "aws_kms_key" "ecr" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for ECR ${var.repository_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  tags                    = var.tags
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration { scan_on_push = true }

  encryption_configuration {
    encryption_type = var.create_kms_key ? "KMS" : "AES256"
    kms_key         = var.create_kms_key ? aws_kms_key.ecr[0].arn : null
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 14 days"
        selection = { tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = 14 }
        action    = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 20 tagged images"
        selection = { tagStatus = "tagged", tagPrefixList = [""], countType = "imageCountMoreThan", countNumber = 20 }
        action    = { type = "expire" }
      }
    ]
  })
}
