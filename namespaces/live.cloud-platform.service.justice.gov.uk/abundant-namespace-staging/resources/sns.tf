/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "abundant_namespace_staging_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.6.0"

  topic_display_name     = "abundant-staging-sns"
  business_unit          = "hq"
  application            = "abundant-namespace-staging"
  is_production          = "false"
  team_name              = "webops"
  environment_name       = "staging"
  infrastructure_support = "cloud-platform"
  namespace              = "abundant-namespace-staging"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_sns_topic" {
  metadata {
    name      = "sns-topic-sns-user"
    namespace = "abundant-namespace-staging"
  }

  data = {
    access_key_id     = module.abundant_namespace_staging_sns.access_key_id
    secret_access_key = module.abundant_namespace_staging_sns.secret_access_key
    topic_arn         = module.abundant_namespace_staging_sns.topic_arn
  }
}

