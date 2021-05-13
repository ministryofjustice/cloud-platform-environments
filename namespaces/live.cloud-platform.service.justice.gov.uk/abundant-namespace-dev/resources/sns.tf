module "example_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.2"

  team_name          = "webops"
  topic_display_name = "cp-live-test"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sns_topic" {
  metadata {
    name      = "example-sns-output"
    namespace = "abundant-namespace-dev"
  }

  data = {
    access_key_id     = module.example_sns_topic.access_key_id
    secret_access_key = module.example_sns_topic.secret_access_key
    topic_arn         = module.example_sns_topic.topic_arn
  }
}

