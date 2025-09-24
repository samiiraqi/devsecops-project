resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"  # GitHub's SSL cert thumbprint
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.subjects
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "deploy" {
  # --- App deployment: ECR & EKS ---
  statement {
    sid       = "ECRRepo"
    effect    = "Allow"
    actions   = var.allow_ecr_actions
    resources = [var.ecr_repo_arn, "${var.ecr_repo_arn}/*"]
  }

  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid       = "EksDescribe"
    effect    = "Allow"
    actions   = var.allow_eks_actions
    resources = ["*"]
  }

  statement {
    sid       = "STSIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  # --- S3 All Operations ---
  statement {
    sid     = "S3AllOperations"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::devsecops-156041402173-us-east-1",
      "arn:aws:s3:::devsecops-156041402173-us-east-1/*",
      "arn:aws:s3:::devsecops-project-app-156041402173-us-east-1",
      "arn:aws:s3:::devsecops-project-app-156041402173-us-east-1/*"
    ]
  }

  # --- Terraform: DynamoDB lock table ---
  statement {
    sid     = "TerraformDynamoDB"
    effect  = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-1:156041402173:table/terraform-locks"
    ]
  }

  # --- Terraform & EKS admin ---
  statement {
    sid       = "EksAdmin"
    effect    = "Allow"
    actions   = ["eks:*", "iam:PassRole"]
    resources = ["*"]
  }

  # --- EC2 Operations ---
  statement {
    sid    = "EC2Operations"
    effect = "Allow"
    actions = ["ec2:*"]
    resources = ["*"]
  }

  # --- IAM Operations ---
statement {
  sid    = "IAMOperations"
  effect = "Allow"
  actions = [
    "iam:CreateRole",
    "iam:DeleteRole", 
    "iam:GetRole",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
    "iam:CreateOpenIDConnectProvider",
    "iam:DeleteOpenIDConnectProvider",
    "iam:GetOpenIDConnectProvider",
    "iam:CreatePolicy",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:ListPolicyVersions",
    "iam:DeletePolicy",
    "iam:DeletePolicyVersion",
    "iam:CreatePolicyVersion",
    "iam:TagRole",
    "iam:ListRolePolicies",
    "iam:ListAttachedRolePolicies",
    "iam:GetRolePolicy"
  ]
  resources = ["*"]
}

  # --- ECR Operations ---
  statement {
    sid    = "ECROperations"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "deploy" {
  name   = "${var.role_name}-policy"
  policy = data.aws_iam_policy_document.deploy.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.deploy.arn
}