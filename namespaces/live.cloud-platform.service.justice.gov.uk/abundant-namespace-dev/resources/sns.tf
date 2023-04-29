/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "abundant_namespace_dev_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.8.0"

  topic_display_name     = "test-sns"
  business_unit          = "hq"
  application            = "abundant-namespace-dev"
  is_production          = "false"
  team_name              = "webops"
  environment_name       = "dev"
  infrastructure_support = "cloud-platform"
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
    access_key_id     = module.abundant_namespace_dev_sns.access_key_id
    secret_access_key = module.abundant_namespace_dev_sns.secret_access_key
    topic_arn         = module.abundant_namespace_dev_sns.topic_arn
  }
}

