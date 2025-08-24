aws_region  = "us-east-1"
name_prefix = "devsecops"

github_org      = "samiiraqi"
github_repo     = "flask-app-k8s"
github_branches = ["main"]

vpc_cidr = "10.0.0.0/16"
az_count = 2

kubernetes_version                   = "1.29"
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

# leave empty to auto-generate <name_prefix>-<account>-<region>

