module "formbuilder_product_page_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"
  repo_name = "formbuilder-product-page"
  team_name = "formbuilder"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "formbuilder_product_page_ecr_credentials" {
  metadata {
    name      = "formbuilder-product-page-ecr-credentials-output"
    namespace = "formbuilder-product-page-prod"
  }

  data {
    access_key        = "${module.formbuilder_product_page_ecr_credentials.access_key_id}"
    secret_access_key = "${module.formbuilder_product_page_ecr_credentials.secret_access_key}"
    repo_arn          = "${module.formbuilder_product_page_ecr_credentials.repo_arn}"
    repo_url          = "${module.formbuilder_product_page_ecr_credentials.repo_url}"
  }
}
