output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app_ecr.repository_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.app_table.name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "random_suffix" {
  description = "Random suffix used for unique naming"
  value       = random_string.suffix.result
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "app_url_instructions" {
  description = "How to get your app URL after deploying"
  value       = "After deploying app: kubectl get svc -n flask-app flask-app-service"
}