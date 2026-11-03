data "aws_iam_policy_document" "hmpps_snyk_discovery_business_unit_ecr_pull" {
  statement {
    sid     = "AllowEcrLogin"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPullFromHmppsTaggedEcr"
    effect = "Allow"

    actions = [
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/business-unit"
      values   = ["HMPPS"]
    }
  }
}

resource "aws_iam_policy" "hmpps_business_unit_ecr_pull" {
  name   = "hmpps-portfolio-management-dev-snyk-discovery-hmpps-ecr-pull"
  policy = data.aws_iam_policy_document.hmpps_snyk_discovery_business_unit_ecr_pull.json
}
