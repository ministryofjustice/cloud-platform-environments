resource "random_id" "id" {
  byte_length = 8
}

resource "aws_iam_user" "user" {
  name = "data-compliance-preprod-ap-user-${random_id.id.hex}"
  path = "/system/data-compliance-ap-users/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
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
