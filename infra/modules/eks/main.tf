data "aws_iam_policy" "eks_worker" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_cni" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "ecr_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "node_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = var.node_role_name
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node_attach_worker" {
  role       = aws_iam_role.node.name
  policy_arn = data.aws_iam_policy.eks_worker.arn
}

resource "aws_iam_role_policy_attachment" "node_attach_cni" {
  role       = aws_iam_role.node.name
  policy_arn = data.aws_iam_policy.eks_cni.arn
}

resource "aws_iam_role_policy_attachment" "node_attach_ecr" {
  role       = aws_iam_role.node.name
  policy_arn = data.aws_iam_policy.ecr_readonly.arn
}

resource "aws_iam_role_policy_attachment" "node_attach_ssm" {
  role       = aws_iam_role.node.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"
  access_entries = var.access_entries
  cluster_name    = var.name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_irsa              = true
  cluster_enabled_log_types = ["api","audit","authenticator","scheduler","controllerManager"]

  # Do NOT set manage_aws_auth or aws_auth_roles on v20+. You'll apply aws-auth via YAML.
  # If later you want to manage access via the module, use 'access_entries' (v20+) instead.

  eks_managed_node_groups = {
    default = {
      name           = "default"
      instance_types = ["t3.medium"]
      min_size       = 1
      desired_size   = 2
      max_size       = 4
      disk_size      = 20

      iam_role_arn = aws_iam_role.node.arn
    }
  }

  tags = var.tags
}

  
