module "crime_batch_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "ac-crime-batch"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "crime_batch_sns_topic" {
  metadata {
    name      = "crime-batch-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.crime_batch_sns.topic_arn
    topic_name = module.crime_batch_sns.topic_name
  }
}

# TODO filter policy?
resource "aws_sns_topic_subscription" "queue" {
  topic_arn     = module.crime_batch_sns.topic_arn
  endpoint      = module.crime_batch_sqs.sqs_arn
  protocol      = "sqs"
}