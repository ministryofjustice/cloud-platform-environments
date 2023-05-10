terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "probation-integration"
  region = "eu-west-2"
  default_tags {
    tags = {
      GithubTeam = "probation-integration"
    }
  }
}

provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}

locals {
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

# Add outputs that need to be consumed in other namespaces here
resource "aws_ssm_parameter" "tf-outputs" {
  type = "String"
  name = "/${var.namespace}/tf-outputs"
  value = jsonencode({
    "rp_domain-events_sqs_irsa_policy_arn" : module.restricted_patients_queue_for_domain_events.irsa_policy_arn
    "rp_domain-events_dlq_sqs_irsa_policy_arn" : module.restricted_patients_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
    "hmpps_domain_events_topic_arn" : module.hmpps-domain-events.topic_arn
    "hmpps_domain_events_irsa_policy_arn" : module.hmpps-domain-events.irsa_policy_arn
  })
  tags = local.tags
}
