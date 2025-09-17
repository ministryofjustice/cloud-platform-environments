module "ims_images_storage_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
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

resource "kubernetes_secret" "ims_images_storage_bucket" {
  metadata {
    name      = "ims-images-storage-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.ims_images_storage_bucket.bucket_arn
    bucket_name = module.ims_images_storage_bucket.bucket_name
  }
}

module "ims_attachments_storage_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
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

resource "kubernetes_secret" "ims_attachments_storage_bucket" {
  metadata {
    name      = "ims-attachments-storage-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.ims_attachments_storage_bucket.bucket_arn
    bucket_name = module.ims_attachments_storage_bucket.bucket_name
  }
}