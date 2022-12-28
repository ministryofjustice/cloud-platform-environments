module "example_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=refactoring"

  team_name          = var.team_name
  topic_display_name = "jakemulley-development"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  owner                  = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}
