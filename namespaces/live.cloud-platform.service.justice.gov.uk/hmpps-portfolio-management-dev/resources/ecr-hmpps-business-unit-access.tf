data "aws_caller_identity" "current" {}

# Find Snyk discovery ECR GitHub OIDC roles across the whole AWS account.
data "aws_resourcegroupstaggingapi_resources" "hmpps_snyk_discovery_ecr_roles_account_wide" {
  resource_type_filters = ["iam:role"]

  tag_filter {
    key    = "application"
    values = ["hmpps-snyk-discovery"]
  }

  # Ensure the module-created roles exist before this lookup runs.
  depends_on = [
    module.hmpps_synk_discovery,
  ]
}

data "aws_iam_policy_document" "hmpps_snyk_discovery_business_unit_ecr_pull" {
  statement {
    sid    = "AllowPullFromHmppsTaggedEcr"
    effect = "Allow"

    actions = [
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

resource "aws_iam_role_policy_attachment" "hmpps_business_unit_ecr_pull" {
  for_each = toset([
    for mapping in data.aws_resourcegroupstaggingapi_resources.hmpps_snyk_discovery_ecr_roles_account_wide.resource_tag_mapping_list :
    replace(mapping.resource_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/", "")
  ])

  role       = each.value
  policy_arn = aws_iam_policy.hmpps_business_unit_ecr_pull.arn
}
