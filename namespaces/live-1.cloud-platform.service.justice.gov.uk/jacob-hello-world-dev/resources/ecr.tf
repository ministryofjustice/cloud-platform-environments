/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_team_ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=4.3"
  repo_name = "jacobbrowning-dev-repo"
  team_name = "jacobbrowning-dev-team"
  /*
    By default scan_on_push is set to true. When this is enabled then all images pushed to the repo are scanned for any security
    / software vulnerabilities in your image and the results can be viewed in the console. For further details, please see: 
    https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html 
    To disable 'scan_on_push', set it to false as below:
  scan_on_push = "false"  
  */

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ecr_credentials" {
  metadata {
    name      = "jacob-hello-world-dev-ecr-credentials-output"
    namespace = "jacob-hello-world-dev"
  }

  data = {
    access_key_id     = module.example_team_ecr_credentials.access_key_id
    secret_access_key = module.example_team_ecr_credentials.secret_access_key
    repo_arn          = module.example_team_ecr_credentials.repo_arn
    repo_url          = module.example_team_ecr_credentials.repo_url
  }
}
