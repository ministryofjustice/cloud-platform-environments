locals {
  sqs_allowed_applications = toset(concat([var.application], var.sqs_queue_subscriber_applications))
  sqs_matching_role_names = [
    for arn in data.aws_iam_roles.sqs_subscriber_roles.arns :
    replace(arn, "/arn:aws:iam::[0-9]+:role\\//", "")
  ]
  sqs_roles_with_app_tag = {
    for name, role in data.aws_iam_role.sqs_matching_roles :
    name => role
    if lookup(role.tags, "application", null) != null &&
    (
      role.tags["application"] == var.application ||
      contains(local.sqs_allowed_applications, role.tags["application"])
    )
  }
}
