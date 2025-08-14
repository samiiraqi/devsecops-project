output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "s3_bucket_name" {
  value = module.storage.bucket_name
}

output "dynamodb_table_name" {
  value = module.storage.dynamodb_table_name
}

output "kubectl_cmd" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
