data "aws_iam_policy_document" "athena_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.em_datastore_general_role,
      var.em_datastore_specials_role
    ]
  }
}

resource "aws_iam_policy" "athena_access" {
  name   = "${var.namespace}-policy-general"
  policy = data.aws_iam_policy_document.athena_policy.json
  tags = local.tags
}
