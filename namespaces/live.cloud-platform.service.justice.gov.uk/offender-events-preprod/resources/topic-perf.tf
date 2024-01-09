module "probation_offender_events_perf" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "probation-offender-events-perf"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}
