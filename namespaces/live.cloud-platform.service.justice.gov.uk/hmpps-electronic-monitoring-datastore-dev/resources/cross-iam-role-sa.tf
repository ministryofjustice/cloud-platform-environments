
locals {
  # The names of the queues used and the namespace which created them
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue" = "hmpps-audit-dev"

  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "${var.namespace-short}-athena"
  namespace            = var.namespace
  role_policy_arns = merge(
    local.sqs_policies,
    {
      athena = aws_iam_policy.athena_access.arn
    }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "document" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_ssm_parameter.athena_general_role_arn.value,
      aws_ssm_parameter.athena_specials_role_arn.value,
    ]
  }
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

resource "aws_iam_policy" "athena_access" {
  name   = "${var.namespace}-athena-policy-general"
  policy = data.aws_iam_policy_document.document.json

  tags = local.tags
}
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

resource "kubernetes_secret" "athena_roles" {
  metadata {
    name      = "${var.namespace}-athena-roles"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    general_role_arn = aws_ssm_parameter.athena_general_role_arn.value
    specials_role_arn = aws_ssm_parameter.athena_specials_role_arn.value
  }
}
