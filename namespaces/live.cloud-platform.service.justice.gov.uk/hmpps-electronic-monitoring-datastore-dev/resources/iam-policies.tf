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

  # Tags
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace # this is also used to attach your service account to your namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
