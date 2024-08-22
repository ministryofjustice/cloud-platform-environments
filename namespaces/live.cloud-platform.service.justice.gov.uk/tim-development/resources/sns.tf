module "sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.2" # use the latest release

  # Configuration
  topic_display_name = "example-sns"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


module "sns_topic_fifo" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=sns-fifo" # use the latest release

  # Configuration
  topic_display_name = "example-sns-fifo"
  encrypt_sns_kms    = true
  fifo_topic         = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
