module "formbuilder_product_page_staging_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "formbuilder-product-page-staging"
  team_name = "formbuilder"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "formbuilder_product_page_staging_ecr_credentials" {
  metadata {
    name      = "formbuilder-product-page-staging-ecr-credentials-output"
    namespace = "formbuilder-product-page-staging"
  }

  data = {
    access_key        = module.formbuilder_product_page_staging_ecr_credentials.access_key_id
    secret_access_key = module.formbuilder_product_page_staging_ecr_credentials.secret_access_key
    repo_arn          = module.formbuilder_product_page_staging_ecr_credentials.repo_arn
    repo_url          = module.formbuilder_product_page_staging_ecr_credentials.repo_url
  }
}

