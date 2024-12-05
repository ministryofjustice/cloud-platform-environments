module "formbuilder_product_page_staging_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=7.0.0"
  repo_name = "formbuilder-product-page-staging"

  oidc_providers      = ["circleci"]
  github_repositories = ["formbuilder-product-page"]

  providers = {
    aws = aws.london
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "formbuilder" # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "formbuilder_product_page_staging_ecr_credentials" {
  metadata {
    name      = "formbuilder-product-page-staging-ecr-credentials-output"
    namespace = "formbuilder-product-page-staging"
  }

  data = {
    repo_arn = module.formbuilder_product_page_staging_ecr_credentials.repo_arn
    repo_url = module.formbuilder_product_page_staging_ecr_credentials.repo_url
  }
}
