# ============================================================
# GitHub Actions OIDC Provider
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}


# ============================================================
# GitHub Actions IAM Role
#
# Repository:
# mim8640/aws-msa-platform
#
# GitHub Immutable OIDC Subject:
# repo:mim8640@129764335/aws-msa-platform@1429119783:ref:refs/heads/main
# ============================================================

resource "aws_iam_role" "github_actions" {
  name = "github-actions-msa-platform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"

            "token.actions.githubusercontent.com:sub" = [
              "repo:mim8640@129764335/aws-msa-platform@1429119783:ref:refs/heads/main",
              "repo:mim8640@129764335/aws-infra@1429119383:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-msa-platform"
  }
}


# ============================================================
# GitHub Actions -> ECR Push Policy
# ============================================================

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "github-actions-msa-platform-ecr"
  description = "Allow GitHub Actions to push MSA images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      # ------------------------------------------------------
      # ECR Login
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      # ------------------------------------------------------
      # Push/Pull MSA Images
      # ------------------------------------------------------
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = [
          "arn:aws:ecr:ap-northeast-2:253041091860:repository/api-gateway",
          "arn:aws:ecr:ap-northeast-2:253041091860:repository/member-service",
          "arn:aws:ecr:ap-northeast-2:253041091860:repository/product-service",
          "arn:aws:ecr:ap-northeast-2:253041091860:repository/order-service",
          "arn:aws:ecr:ap-northeast-2:253041091860:repository/frontend"
        ]
      }
    ]
  })

  tags = {
    Name = "github-actions-msa-platform-ecr"
  }
}


# ============================================================
# Attach ECR Policy to GitHub Actions Role
# ============================================================

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}


# ============================================================
# Outputs
# ============================================================

output "github_actions_role_arn" {
  description = "IAM Role used by GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}

# ============================================================
# GitHub Actions -> Terraform ReadOnly
# ============================================================

resource "aws_iam_role_policy_attachment" "github_actions_readonly" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
# ============================================================
# GitHub Actions -> Terraform S3 State Access
# ============================================================

resource "aws_iam_policy" "github_actions_tfstate" {
  name        = "${var.project}-github-actions-tfstate"
  description = "Allow GitHub Actions to access Terraform remote state"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListTerraformStateBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::msa-platform-253041091860-ap-northeast-2-tfstate"
      },
      {
        Sid    = "AccessTerraformState"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = [
          "arn:aws:s3:::msa-platform-253041091860-ap-northeast-2-tfstate/aws-infra/terraform.tfstate",
          "arn:aws:s3:::msa-platform-253041091860-ap-northeast-2-tfstate/aws-infra/terraform.tfstate.tflock"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_tfstate" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_tfstate.arn
}
# ============================================================
# GitHub Actions -> Redis Secret Read Access
# Terraform plan refresh에 필요
# ============================================================

resource "aws_iam_policy" "github_actions_secrets_read" {
  name        = "${var.project}-github-actions-secrets-read"
  description = "Allow GitHub Actions Terraform CI to read project secrets"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadProjectSecrets"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.project}/redis-*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_secrets_read" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_secrets_read.arn
}
