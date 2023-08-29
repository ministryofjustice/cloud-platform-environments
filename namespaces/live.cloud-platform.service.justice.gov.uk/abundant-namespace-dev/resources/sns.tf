/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "abundant_namespace_dev_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=4.10.0"

  # Configuration
  topic_display_name = "test-sns"

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
    access_key_id     = module.abundant_namespace_dev_sns.access_key_id
    secret_access_key = module.abundant_namespace_dev_sns.secret_access_key
    topic_arn         = module.abundant_namespace_dev_sns.topic_arn
  }
}
