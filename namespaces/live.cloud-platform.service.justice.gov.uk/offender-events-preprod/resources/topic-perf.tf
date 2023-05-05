module "probation_offender_events_perf" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"
  topic_display_name = "probation-offender-events-perf"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}
