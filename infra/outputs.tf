output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "aws_region" {
  value = var.aws_region
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "s3_bucket_name" {
  value = module.storage.bucket_name
}

output "dynamodb_table_name" {
  value = module.storage.table_name
}

output "github_actions_role_arn" {
  value = module.github_oidc.role_arn
}

output "kubectl_cmd" {
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
  description = "Command to configure kubectl"
}