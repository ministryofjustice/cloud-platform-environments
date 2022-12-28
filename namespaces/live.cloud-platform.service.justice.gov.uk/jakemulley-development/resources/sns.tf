module "example_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns?ref=version"

  team_name          = var.team_name
  topic_display_name = "jakemulley-development"

  providers = {
    aws = aws.london
  }
}
