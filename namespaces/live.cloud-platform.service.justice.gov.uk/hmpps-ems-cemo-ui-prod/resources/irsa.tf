locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue" = "hmpps-audit-prod",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

resource "aws_iam_policy" "cross_namespace_s3_policy" {
  name   = "${var.namespace}-cross-namespace-s3-policy"
  policy = data.aws_iam_policy_document.cross_namespace_s3_access.json
}

data "aws_iam_policy_document" "cross_namespace_s3_access" {
  statement {
    sid = "AllowReadWriteAccessToCrossNamespaceS3Bucket"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${data.aws_ssm_parameter.large-court-cases-s3-bucket-arn.value}/*", ]
  }
}

module "create_an_order_api_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-electronic-monitoring-create-an-order-api"
  role_policy_arns     = merge(
    local.sqs_policies,
    { s3 = aws_iam_policy.cross_namespace_s3_policy.arn },
    {court_case_events_fifo_queue             = module.court_case_events_fifo_queue.irsa_policy_arn},
    {court_case_events_fifo_dead_letter_queue = module.court_case_events_fifo_dead_letter_queue.irsa_policy_arn}
  )
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.create_an_order_api_irsa.role_name
    serviceaccount = module.create_an_order_api_irsa.service_account.name
    rolearn        = module.create_an_order_api_irsa.role_arn
  }
}
