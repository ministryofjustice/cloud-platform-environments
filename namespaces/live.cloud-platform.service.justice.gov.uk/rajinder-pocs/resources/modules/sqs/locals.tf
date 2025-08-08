locals {
  /* The "sqs" locals below are used to transform the data from the lookups in data.tf and used to
  pass data to a suitable sqs access policy. */
  sqs_allowed_namespaces = toset(concat([var.namespace], var.sqs_queue_subscriber_namespaces))
  sqs_matching_role_names = [
    for arn in data.aws_iam_roles.sqs_subscriber_roles.arns :
    replace(arn, "/arn:aws:iam::[0-9]+:role\\//", "")
  ]
  sqs_roles_with_namespace_tag = {
    for name, role in data.aws_iam_role.sqs_matching_roles :
    name => role
    if can(role.tags["namespace"]) &&
    (
      role.tags["namespace"] == var.namespace ||
      contains(local.sqs_allowed_namespaces, role.tags["namespace"])
    )
  }
}
