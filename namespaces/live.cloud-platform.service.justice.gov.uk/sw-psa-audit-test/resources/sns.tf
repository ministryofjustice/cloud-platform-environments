/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "steve_test_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  # Configuration
  topic_display_name = "steve-test-sns"

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

resource "kubernetes_secret" "example_sns_topic" {
  metadata {
    name      = "sns-topic-sns-user"
    namespace = var.namespace
  }

  data = {
    topic_arn = steve_test_sns.topic_arn
  }
}
