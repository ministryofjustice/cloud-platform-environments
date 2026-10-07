# IAM policy that allows sending messages to the HMPPS Audit queue, published to SSM by hmpps-audit-dev
data "aws_ssm_parameter" "hmpps_audit_queue_irsa_policy_arn" {
  provider = aws.london
  name     = "/hmpps-audit-dev/sqs/Digital-Prison-Services-dev-hmpps_audit_queue/irsa-policy-arn"
}

# Service account for the manage adjudications front end, so it can send page-view
# events to the HMPPS Audit queue. Deliberately separate from the manage-adjudications
# service account in servicepod.tf, which belongs to the service pod and only has Redis access.
# The helm chart must set generic-service.serviceAccountName to match the name below.
module "hmpps-manage-adjudications-ui-service-account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-manage-adjudications-ui"
  role_policy_arns = {
    audit_sqs = data.aws_ssm_parameter.hmpps_audit_queue_irsa_policy_arn.value
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
