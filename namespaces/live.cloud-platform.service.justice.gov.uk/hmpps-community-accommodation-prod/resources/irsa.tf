# Get the ARN of the IRSA policy for the SQS queue
data "aws_ssm_parameter" "irsa_policy_arns_sns_domain_events" {
  name     = "/hmpps-domain-events-prod/sns/cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08/irsa-policy-arn"
}

# Get the ARN of the IRSA policy for the SNS topic
data "aws_ssm_parameter" "irsa_policy_arns_sqs_audit" {
  name     = "/hmpps-audit-prod/sqs/Digital-Prison-Services-prod-hmpps_audit_queue/irsa-policy-arn"
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-community-accommodation-api-service-account"
  namespace            = var.namespace
  role_policy_arns = {
    cas-2-sns           = module.cas-2-domain-events-queue.irsa_policy_arn,
    domain_events_topic = data.aws_ssm_parameter.irsa_policy_arns_sns_domain_events.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_ap" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-approved-premises-service-account"
  namespace            = var.namespace
  role_policy_arns = {
    audit_sqs = data.aws_ssm_parameter.irsa_policy_arns_sqs_audit.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_cas2" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-community-accommodation-tier-2-service-account"
  namespace            = var.namespace
  role_policy_arns = {
    audit_sqs = data.aws_ssm_parameter.irsa_policy_arns_sqs_audit.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_ta" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-temporary-accommodation-service-account"
  namespace            = var.namespace
  role_policy_arns = {
    audit_sqs = data.aws_ssm_parameter.irsa_policy_arns_sqs_audit.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
