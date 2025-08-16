resource "aws_iam_openid_connect_provider" "github" {
  count          = var.use_existing_provider ? 0 : 1
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = { Name = "GitHub-OIDC" }
}

locals {
  provider_arn = var.use_existing_provider ? var.existing_provider_arn : aws_iam_openid_connect_provider.github[0].arn
}

resource "aws_iam_role" "gha_role" {
  name = "${var.cluster_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sts:AssumeRoleWithWebIdentity",
      Principal = { Federated = local.provider_arn },
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" = "repo:${var.repo_full_name}:${var.branch_ref}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_ecr_poweruser" {
  role       = aws_iam_role.gha_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy" "gha_eks_read" {
  name        = "${var.cluster_name}-gha-eks-read"
  description = "Minimal EKS read for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Action=["eks:DescribeCluster"], Resource="*" }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_eks_read_attach" {
  role       = aws_iam_role.gha_role.name
  policy_arn = aws_iam_policy.gha_eks_read.arn
}
