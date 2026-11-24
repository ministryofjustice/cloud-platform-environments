data "aws_iam_policy_document" "assume_datastore_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.datastore_role_arn,
    ]
  }
}

# Creates a policy that allows the principal to assume a role in the 
# Electronic Monitoring Datastore account (Modernisation Platform)
resource "aws_iam_policy" "assume_datastore_role" {
  name   = "${var.namespace}-assume-datastore-role"
  policy = data.aws_iam_policy_document.assume_datastore_role.json
  tags = local.tags
}
