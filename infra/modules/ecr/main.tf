resource "aws_ecr_repository" "this" {
  name = var.repository_name

  image_scanning_configuration { scan_on_push = true }
  tags = var.tags

  lifecycle {
    ignore_changes = [
      image_tag_mutability,
      encryption_configuration,
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.enable_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy
}
