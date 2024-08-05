data "aws_iam_policy_document" "mojap-rd_access_policy_doc" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::mojap-rd",
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::mojap-rd/*"
    ]
  }
}

resource "aws_iam_policy" "mojap-rd_access_policy" {
  name   = "rd-hr-smart-knowledge-management-dev_rd_access_policy"
  policy = data.aws_iam_policy_document.mojap-rd_access_policy_doc.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}
