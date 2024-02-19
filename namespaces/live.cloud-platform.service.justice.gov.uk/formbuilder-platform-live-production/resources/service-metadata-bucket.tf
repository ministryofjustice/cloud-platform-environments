module "service-metadata-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = "transformed-department"
  application            = "formbuilderservicemetadata"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "service-metadata-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "service-metadata-irsa-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3 = module.service-metadata-s3-bucket.irsa_policy_arn
  }

  # Tags

  team_name              = var.team_name
  business_unit          = "transformed-department"
  application            = "formbuilderservicemetadata"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "service-metadata-s3-bucket" {
  metadata {
    name      = "s3-service-metadata-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    bucket_arn  = module.service-metadata-s3-bucket.bucket_arn
    bucket_name = module.service-metadata-s3-bucket.bucket_name
  }
}

resource "kubernetes_secret" "service-metadata-s3-arn-cross-namespace" {
  metadata {
    name      = "service-metadata-s3-policy-arn"
    namespace = "formbuilder-services-live-production"
  }

  data = {
    s3arn = module.service-metadata-s3-bucket.irsa_policy_arn
  }
}