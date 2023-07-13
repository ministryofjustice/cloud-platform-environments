module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_s3_bucket_object" "backup_pdf_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees_backup/PDF_Files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "backup_status_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees_backup/Status_Files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "backup_xml_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees_backup/XML_Files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "pdf_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees.files/PDF_Files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "status_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees.files/Status_Files/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "xml_directory" {
  bucket       = module.s3_bucket.bucket_name
  key          = "IACFees.files/XML_Files/"
  content_type = "application/x-directory"
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3_bucket.access_key_id
    secret_access_key = module.s3_bucket.secret_access_key
    bucket_arn        = module.s3_bucket.bucket_arn
    bucket_name       = module.s3_bucket.bucket_name
  }
}
