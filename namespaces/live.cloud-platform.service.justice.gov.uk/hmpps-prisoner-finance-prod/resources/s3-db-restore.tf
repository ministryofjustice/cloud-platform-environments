# Holds
module "holds-restore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  # S3 configuration

  # Tags
  application            = "hmpps-prisoner-finance-holds-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "s3-holds-db-restore" {
  metadata {
    name      = "holds-restore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.holds-restore-s3-bucket.bucket_arn
    bucket_name = module.holds-restore-s3-bucket.bucket_name
  }
}

# Advances

module "advances-restore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  # S3 configuration

  # Tags
  application            = "hmpps-prisoner-finance-advances-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "s3-advances-db-restore" {
  metadata {
    name      = "advances-restore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.advances-restore-s3-bucket.bucket_arn
    bucket_name = module.advances-restore-s3-bucket.bucket_name
  }
}

# Subscriptions

module "subscriptions-restore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  # S3 configuration

  # Tags
  application            = "hmpps-prisoner-finance-subscriptions-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "s3-subscriptions-db-restore" {
  metadata {
    name      = "subscriptions-restore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.subscriptions-restore-s3-bucket.bucket_arn
    bucket_name = module.subscriptions-restore-s3-bucket.bucket_name
  }
}

# PF-API

module "pf-api-restore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  # S3 configuration

  # Tags
  application            = "hmpps-prisoner-finance-api"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "kubernetes_secret" "s3-pf-api-db-restore" {
  metadata {
    name      = "pf-api-restore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.pf-api-restore-s3-bucket.bucket_arn
    bucket_name = module.pf-api-restore-s3-bucket.bucket_name
  }
}
