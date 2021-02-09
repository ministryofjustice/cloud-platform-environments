module "hmpps-domain-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.1"

  team_name          = var.team_name
  topic_display_name = "hmpps-domain-events"

  providers = {
    aws = aws.london
  }
}



