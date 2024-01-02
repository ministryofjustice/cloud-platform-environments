module "cemo_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}


resource "aws_s3_bucket_notification" "cemo_s3_notification" {
  bucket = module.cemo_s3.bucket_name

  queue {
    id = "cemo-s3-upload-event"
    queue_arn = module.cemo_submit_queue.sqs_arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "upload/"
  }
}


resource "kubernetes_secret" "cemo_s3" {
  metadata {
    name      = "cemo-s3"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.cemo_s3.bucket_arn
    bucket_name = module.cemo_s3.bucket_name
  }
}
