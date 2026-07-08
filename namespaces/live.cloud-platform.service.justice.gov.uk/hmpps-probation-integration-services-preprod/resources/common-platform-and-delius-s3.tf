module "common-platform-and-delius-s3-bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "common-platform-and-delius-s3-bucket" {
  metadata {
    name      = "common-platform-and-delius-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.common-platform-and-delius-s3-bucket.bucket_arn
    bucket_name = module.common-platform-and-delius-s3-bucket.bucket_name
  }
}

data "github_repository_file" "offence_priority_csv" {
  repository          = "moj-analytical-services/lookup_offence"
  file                = "data/offence_priority/offence_priority.csv"
}

resource "aws_s3_object" "offence_priority" {
  bucket  = module.common-platform-and-delius-s3-bucket.bucket_name
  key     = "offence_priority.csv"
  content = data.github_repository_file.offence_priority_csv.content
  etag    = data.github_repository_file.offence_priority_csv.sha
}
