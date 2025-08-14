# --- OIDC provider (create only if your account doesn't already have one) ---
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = { Name = "GitHub-OIDC" }
}

# --- IAM role GitHub Actions will assume ---
resource "aws_iam_role" "gha_role" {
  name = "${var.cluster_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRoleWithWebIdentity",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          # 👇 CHANGE THIS to your repo "owner/repo" and branch "main"
          "token.actions.githubusercontent.com:sub" = "repo:samiiraqi/flask-app-k8s:ref:refs/heads/main"
        }
      }
    }]
  })
}

# --- Permissions for the workflow ---
# Push/pull images to ECR
resource "aws_iam_role_policy_attachment" "gha_ecr_poweruser" {
  role       = aws_iam_role.gha_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Read EKS cluster info so kubectl can connect
resource "aws_iam_policy" "gha_eks_read" {
  name        = "${var.cluster_name}-gha-eks-read"
  description = "Minimal EKS read for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["eks:DescribeCluster"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_eks_read_attach" {
  role       = aws_iam_role.gha_role.name
  policy_arn = aws_iam_policy.gha_eks_read.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.gha_role.arn
}
