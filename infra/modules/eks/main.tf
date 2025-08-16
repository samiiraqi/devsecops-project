module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name                   = var.cluster_name
  cluster_version                = var.kubernetes_version
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnet_ids
  cluster_endpoint_public_access = true
  enable_irsa                    = true

  eks_managed_node_groups = {
    main = {
      name           = "${var.cluster_name}-ng"
      instance_types = var.instance_types
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_users = var.aws_auth_users
  aws_auth_roles = var.aws_auth_roles

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}