# S3 bucket: the durable source of truth for curated VSIX files and the
# generated report artifacts.
#
# Cloud Platform provides only S3 and EBS storage. EBS is ReadWriteOnce, so it
# cannot be shared between the separate curator and marketplace pods the way the
# previous EFS (ReadWriteMany) volume was. Instead the curator writes VSIX
# objects to this bucket (no shared mount), and the marketplace pod syncs them
# down to its own local EBS volume via an init container + sidecar.

module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  oidc_providers      = ["github"]
  github_repositories = [var.github_repository]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}
