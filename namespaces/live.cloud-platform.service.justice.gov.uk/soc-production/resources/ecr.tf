module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"

  team_name = var.team_name
  repo_name = "${var.namespace}-ecr"

  /*
    By default scan_on_push is set to true. When this is enabled then all images pushed to the repo are scanned for any security
    / software vulnerabilities in your image and the results can be viewed in the console. For further details, please see:
    https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
    To disable 'scan_on_push', set it to false as below:
  scan_on_push = "false"
  */

  # Uncomment and provide repository names to create github actions secrets
  # containing the ECR name, AWS access key, and AWS secret key, for use in
  # github actions CI/CD pipelines
  github_repositories = ["socreporting", "socentry"]

  github_actions_secret_ecr_name       = var.github_actions_secret_ecr_name
  github_actions_secret_ecr_url        = var.github_actions_secret_ecr_url
  github_actions_secret_ecr_access_key = var.github_actions_secret_ecr_access_key
  github_actions_secret_ecr_secret_key = var.github_actions_secret_ecr_secret_key
}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-${var.namespace}"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
  }
}

