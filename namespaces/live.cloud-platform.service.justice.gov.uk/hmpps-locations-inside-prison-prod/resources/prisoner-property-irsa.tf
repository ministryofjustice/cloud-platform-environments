# Dedicated IRSA service account for hmpps-prisoner-property-api.
# Scoped to this app rather than sharing the locations-inside-prison-api service account.
# Grants: publish/subscribe to the hmpps-domain-events SNS topic (via local.sns_policies,
# already computed in the existing irsa.tf in this folder) and access to its own queue + DLQ.
# The helm chart must set generic-service.serviceAccountName to match the name below.

module "prisoner_property_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-property-api"

  role_policy_arns = merge(
    local.sns_policies, # domain-events topic publish/subscribe (shared local from irsa.tf)
    { (module.prisoner_property_event_queue.sqs_name) = module.prisoner_property_event_queue.irsa_policy_arn },
    { (module.prisoner_property_event_dlq.sqs_name)   = module.prisoner_property_event_dlq.irsa_policy_arn },
  )

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "prisoner_property_irsa" {
  metadata {
    name      = "hmpps-prisoner-property-api-irsa-output"
    namespace = var.namespace
  }

  data = {
    role_arn             = module.prisoner_property_irsa.role_arn
    service_account_name = "hmpps-prisoner-property-api"
  }
}
