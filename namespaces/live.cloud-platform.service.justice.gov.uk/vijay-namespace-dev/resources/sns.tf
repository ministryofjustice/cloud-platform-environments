module "test_sns_topic_creation" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.2"

  team_name          = var.team_name
  topic_display_name = "test_sns_topic_creation"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sns_topic" {
  metadata {
    name      = "test_sns_topic_creation"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.test_sns_topic_creation.access_key_id
    secret_access_key = module.test_sns_topic_creation.secret_access_key
    topic_arn         = module.test_sns_topic_creation.topic_arn
  }
}
