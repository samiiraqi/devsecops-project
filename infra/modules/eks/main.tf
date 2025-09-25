# Cluster IAM role
resource "aws_iam_role" "cluster" {
  name = "${var.name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node IAM role (fixed pattern)
resource "aws_iam_role" "node" {
  name = "${var.name}-eks-cluster-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # needed for nodes
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # needed for VPC CNI
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # needed for pulling images
}

# Keep the cluster Security Group managed to avoid "destroy" in plan
resource "aws_security_group" "cluster" {
  name        = "${var.name}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  

  tags = var.tags
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  # Allow Access Entries + legacy aws-auth
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    # IMPORTANT: Do NOT set vpc_id here (provider infers it from subnet_ids)
    subnet_ids              = var.cluster_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  tags = var.tags
}

# Managed node group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.node_subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    min_size     = var.min_size
    desired_size = var.desired_size
    max_size     = var.max_size
  }

  tags = var.tags
}

# ---- Access Entries with the SAME resource names as before ----
# We read them from var.access_entries[...] but keep resource names fixed
locals {
  ae = var.access_entries
  gh = try(var.access_entries.github_admin, null)
  
  sm = try(var.access_entries.sami_admin, null)
}

# github_admin
resource "aws_eks_access_entry" "github_admin" {
  count        = local.gh != null ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  principal_arn = local.gh.principal_arn
  type         = "STANDARD"
  tags         = var.tags
}

resource "aws_eks_access_policy_association" "github_admin" {
  count         = local.gh != null ? 1 : 0
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.gh.principal_arn
  policy_arn    = local.gh.policy_associations.admin.policy_arn

  access_scope {
    type = local.gh.policy_associations.admin.access_scope.type
  }
}





# sami_admin
resource "aws_eks_access_entry" "sami_admin" {
  count        = local.sm != null ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  principal_arn = local.sm.principal_arn
  type         = "STANDARD"
  tags         = var.tags
}

resource "aws_eks_access_policy_association" "sami_admin" {
  count         = local.sm != null ? 1 : 0
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.sm.principal_arn
  policy_arn    = local.sm.policy_associations.admin.policy_arn

  access_scope {
    type = local.sm.policy_associations.admin.access_scope.type
  }
}
