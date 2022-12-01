module "probation_offender_events_perf" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.4"
  team_name          = var.team_name
  topic_display_name = "probation-offender-events-perf"
  providers = {
    aws = aws.london
  }
}
