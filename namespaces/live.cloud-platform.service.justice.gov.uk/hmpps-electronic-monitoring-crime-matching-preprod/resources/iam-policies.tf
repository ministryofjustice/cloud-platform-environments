data "aws_iam_policy_document" "athena_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.datastore_role
    ]
  }
}

resource "aws_iam_policy" "athena_access" {
  name   = "${var.namespace}-athena-policy-general"
  policy = data.aws_iam_policy_document.athena_policy.json
  tags = local.tags
}
