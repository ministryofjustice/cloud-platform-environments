module "sns_topic_file_upload" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=2.0.0"
  topic_name = "${var.namespace}-file-upload"

  encrypt_sns_kms             = true
  fifo_topic                  = false
  content_based_deduplication = false

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}

module "sns_topic_person_id" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=2.0.0"
  topic_display_name          = "person-id-sns"

  encrypt_sns_kms             = true
  fifo_topic                  = false
  content_based_deduplication = false

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}
