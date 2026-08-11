# IRSA for the JDA Worker — consumes request queue, publishes to response queue.
# CSIP (or another producer/consumer) can attach the SQS module IRSA policies via SSM:
#   /hmpps-justice-data-agent-dev/sqs/<queue-name>/irsa-policy-arn
module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-justice-data-agent-worker"
  namespace            = var.namespace

  role_policy_arns = {
    jda_request_queue   = module.jda_request_queue.irsa_policy_arn
    jda_request_dlq     = module.jda_request_dlq.irsa_policy_arn
    jda_response_queue  = module.jda_response_queue.irsa_policy_arn
    jda_response_dlq    = module.jda_response_dlq.irsa_policy_arn
  }

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
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
