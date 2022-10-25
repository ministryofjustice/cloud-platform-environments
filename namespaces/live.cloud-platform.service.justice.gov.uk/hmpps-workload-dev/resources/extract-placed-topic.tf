module "extract-placed-topic" {
  source = "github.com/carlov20/cloud-platform-terraform-sns-topic?ref=main"

  team_name          = var.team_name
  topic_display_name = "extract-placed-topic"

  providers = {
    aws = aws.london
  }

}



