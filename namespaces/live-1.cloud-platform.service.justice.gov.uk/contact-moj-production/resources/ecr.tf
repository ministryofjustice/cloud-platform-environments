/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "contact-moj_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "contact-moj-ecr"
  team_name = "correspondence"

  # aws_region = "eu-west-2"     # This input is deprecated from version 3.2 of this module

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "contact-moj_ecr_credentials" {
  metadata {
    name      = "contact-moj-ecr-credentials-output"
    namespace = "contact-moj-production"
  }

  data = {
    access_key_id     = module.contact-moj_ecr_credentials.access_key_id
    secret_access_key = module.contact-moj_ecr_credentials.secret_access_key
    repo_arn          = module.contact-moj_ecr_credentials.repo_arn
    repo_url          = module.contact-moj_ecr_credentials.repo_url
  }
}
