module "hmpps-restricted-patients-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  service_account  = "${var.application}-${var.environment-name}"
  role_policy_arns = [
    local.domain-events.hmpps_domain_events_irsa_policy_arn,

    local.domain-events.rp_domain-events_sqs_irsa_policy_arn,
    local.domain-events.rp_domain-events_dlq_sqs_irsa_policy_arn,

    local.offender-events.restricted_patients_queue_irsa_policy_arn,
    local.offender-events.restricted_patients_dql_queue_irsa_policy_arn
  ]
}

data "aws_ssm_parameter" "hmpps-domain-events-tf-outputs" {
  name = "/hmpps-domain-events-dev/tf-outputs"
}

data "aws_ssm_parameter" "offender-events-tf-outputs" {
  name = "/offender-events-dev/tf-outputs"
}

locals {
  domain-events   = jsondecode(data.aws_ssm_parameter.hmpps-domain-events-tf-outputs.value)
  offender-events = jsondecode(data.aws_ssm_parameter.offender-events-tf-outputs.value)
}