# SNS Topics

module "sns_topic_fileupload" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-fileupload-sns"

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

module "sns_topic_personid" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"
  topic_display_name = "${var.namespace}-personid-sns"

  encrypt_sns_kms             = true
  fifo_topic                  = true
  content_based_deduplication = true

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace
}

# Kubernetes Secrets for SNS Topics

resource "kubernetes_secret" "fileupload_sns" {
  metadata {
    name      = "fileupload-sns-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.sns_topic_fileupload.topic_arn
  }
}

resource "kubernetes_secret" "personid_sns" {
  metadata {
    name      = "personid-sns-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.sns_topic_personid.topic_arn
  }
}