/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/master/example
 */
module "book_a_secure_move_documents_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = "Digital and Technology"
  application            = var.application
  infrastructure-support = var.infrastructure-support

  is-production    = var.is-production
  environment-name = var.environment-name
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "book_a_secure_move_documents_s3_bucket" {
  metadata {
    name      = "book-a-secure-move-documents-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.book_a_secure_move_documents_s3_bucket.access_key_id
    secret_access_key = module.book_a_secure_move_documents_s3_bucket.secret_access_key
    bucket_arn        = module.book_a_secure_move_documents_s3_bucket.bucket_arn
    bucket_name       = module.book_a_secure_move_documents_s3_bucket.bucket_name
  }
}

