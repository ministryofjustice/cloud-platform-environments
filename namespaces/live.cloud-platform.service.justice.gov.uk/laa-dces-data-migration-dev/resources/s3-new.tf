module "dces_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.dces_s3_bucket.bucket_arn
    bucket_name = module.dces_s3_bucket.bucket_name
  }
}

resource "aws_s3_bucket_notification" "dces_s3_bucket_object_created_notification" {
  bucket = module.dces_s3_bucket.bucket_name

  queue {
    id        = "dces_s3_bucket-upload-event"
    queue_arn = module.dces_s3_object_created_queue.sqs_arn
    events = [
    "s3:ObjectCreated:*"]
  }

  depends_on = [ module.dces_s3_bucket, module.dces_s3_object_created_queue ]
}