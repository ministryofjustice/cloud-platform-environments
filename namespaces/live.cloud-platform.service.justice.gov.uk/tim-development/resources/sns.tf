# /*
#  * Make sure that you use the latest version of the module by changing the
#  * `ref=` value in the `source` attribute to the latest version listed on the
#  * releases page of this repository.
#  *
#  */
# module "example_sns_topic" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

#   topic_display_name     = "tim-test-topic-display-name"
#   encrypt_sns_kms    = true

#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name # also used for naming the topic
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support

# }

# resource "kubernetes_secret" "example_sns_topic" {
#   metadata {
#     name      = "my-topic-sns-user"
#   }

#   data = {
#     topic_arn         = module.example_sns_topic.topic_arn
#   }
# }