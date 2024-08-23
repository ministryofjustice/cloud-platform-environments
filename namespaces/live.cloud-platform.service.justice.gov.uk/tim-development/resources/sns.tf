module "sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=sns-fifo" # use the latest release

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
  topic_display_name          = "example-sns-fifo"
  encrypt_sns_kms             = true
  fifo_topic                  = true
  content_based_deduplication = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


module "sns_topic_new_branch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=sns-fifo" # use the latest release

  # Configuration
  topic_display_name = "example-sns-by-new-branch"
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