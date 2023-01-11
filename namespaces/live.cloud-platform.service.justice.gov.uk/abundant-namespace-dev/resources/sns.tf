/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "abundance-sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.6.0"

  topic_display_name     = "test-sns"
  business_unit          = "hq"
  application            = "abundant-namespace-dev"
  is_production          = "false"
  team_name              = "webops"
  environment_name       = "dev"
  infrastructure_support = "#cloud-platform"
  namespace              = "abundant-namespace-dev"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sns_topic" {
  metadata {
    name      = "sns-topic-sns-user"
    namespace = "abundant-namespace-dev"
  }

  data = {
    access_key_id     = module.example_sns_topic.access_key_id
    secret_access_key = module.example_sns_topic.secret_access_key
    topic_arn         = module.example_sns_topic.topic_arn
  }
}

