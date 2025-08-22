output "vpc_id"                 { value = module.vpc.vpc_id }
output "private_subnet_ids"     { value = module.vpc.private_subnet_ids }
output "public_subnet_ids"      { value = module.vpc.public_subnet_ids }

output "eks_cluster_name"       { value = module.eks.cluster_name }
output "eks_oidc_provider_arn"  { value = module.eks.oidc_provider_arn }

output "ecr_repository_url"     { value = module.ecr.repository_url }
output "github_actions_role_arn"{ value = module.github_oidc.role_arn }
output "s3_bucket_name"         { value = module.storage.bucket_name }
