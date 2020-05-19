resource "random_id" "id" {
  byte_length = 8
}

data "aws_iam_policy_document" "data_compliance_preprod_ap_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::593291632749:role/pulumi_typescript_nomis_gdpr_role-aa611b4",
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "data-compliance-preprod-ap-user-${random_id.id.hex}"
  path = "/system/data-compliance-ap-users/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "data-compliance-ap-policy"
  policy = data.aws_iam_policy_document.data_compliance_preprod_ap_policy.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "data_compliance_ap_user" {
  metadata {
    name      = "data-compliance-ap-user"
    namespace = var.namespace
  }

  data = {
    data_compliance_ap_user_arn          = aws_iam_user.user.arn
    data_compliance_ap_access_key_id     = aws_iam_access_key.user.id
    data_compliance_ap_secret_access_key = aws_iam_access_key.user.secret
  }
}
