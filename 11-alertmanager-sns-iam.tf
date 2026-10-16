# ============================================================
# Alertmanager -> SNS IRSA
# ============================================================

# ------------------------------------------------------------
# IAM Policy
# Alertmanager가 SNS Topic에 Publish 할 수 있도록 허용
# ------------------------------------------------------------
resource "aws_iam_policy" "alertmanager_sns" {
  name = "msa-platform-alertmanager-sns"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sns:Publish"

        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })

  tags = {
    Name = "msa-platform-alertmanager-sns"
  }
}


# ------------------------------------------------------------
# IAM Role
# monitoring namespace의 Alertmanager ServiceAccount만
# 이 Role을 Assume 할 수 있음
# ------------------------------------------------------------
resource "aws_iam_role" "alertmanager_sns" {
  name = "msa-platform-alertmanager-sns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"

            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:monitoring:monitoring-kube-prometheus-alertmanager"
          }
        }
      }
    ]
  })

  tags = {
    Name = "msa-platform-alertmanager-sns"
  }
}


# ------------------------------------------------------------
# Policy -> Role 연결
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "alertmanager_sns" {
  role       = aws_iam_role.alertmanager_sns.name
  policy_arn = aws_iam_policy.alertmanager_sns.arn
}
