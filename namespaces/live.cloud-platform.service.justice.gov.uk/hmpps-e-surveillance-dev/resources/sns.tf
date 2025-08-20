module "sns_topic_file_upload" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-file-upload-sns"

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name          = "${var.namespace}-person-id-sns"

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

resource "kubernetes_secret" "file_upload_sns_topic" {
  metadata {
    name = "file-upload-sns-topic"
    namespace = var.namespace

  }

  data = {
    topic_arn = module.sns_topic_file_upload.topic_arn
  }
}

resource "kubernetes_secret" "person_id_sns_topic" {
  metadata {
    name = "person-id-sns-topic"
    namespace = var.namespace

  }

  data = {
    topic_arn = module.sns_topic_person_id.topic_arn
  }
}

resource "aws_sns_topic_subscription" "file_upload_ingest" {
  topic_arn = module.sns_topic_file_upload.topic_arn
  protocol  = "https"
  endpoint  = "${var.base_url}/ingest"
}

resource "aws_sns_topic_subscription" "person_id_ingest_events" {
  topic_arn = module.sns_topic_person_id.topic_arn
  protocol  = "https"
  endpoint  = "${var.base_url}/ingest/events"
}