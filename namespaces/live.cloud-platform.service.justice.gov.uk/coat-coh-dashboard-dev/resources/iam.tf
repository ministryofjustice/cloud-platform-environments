data "aws_iam_policy_document" "athena_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::593291632749:role/alpha_app_coat-coh-dashboard"]
  }
}

resource "aws_iam_policy" "athena_assume_role" {
  name        = "${var.namespace}-athena-assume-role"
  description = "Allows the Athena ServiceAccount to assume the Analytical Platform role"
  policy      = data.aws_iam_policy_document.athena_assume_role.json
}