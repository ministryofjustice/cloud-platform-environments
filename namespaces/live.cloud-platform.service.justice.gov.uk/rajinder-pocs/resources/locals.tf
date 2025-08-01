locals {
  sqs_allowed_applications = toset(concat([var.application], var.sqs_queue_subscriber_applications))
  sqs_matching_role_names = [
    for arn in data.aws_iam_roles.sqs_subscriber_roles.arns :
    replace(arn, "arn:aws:iam::[0-9]+:role/", "")
  ]

  roles_with_app_tag = {
    for name, role in data.aws_iam_role.sqs_matching_roles :
    name => role
    if anytrue([
      for tag in role.tags :
      tag.key == "application" && contains(local.sqs_allowed_applications, tag.value)
    ])
  }
}
