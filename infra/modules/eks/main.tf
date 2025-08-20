module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.0, < 21.0"

  # Cluster
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # Networking
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Managed node group (simple default)
  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
    }
  }

  # NOTE: In v20+, aws-auth is NOT managed here.
  # We apply aws-auth via k8s/aws-auth.yaml in GitHub Actions after the cluster exists.
}
