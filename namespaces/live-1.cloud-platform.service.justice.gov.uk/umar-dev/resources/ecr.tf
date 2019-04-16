module "umar-dev-ecr-credentials" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.1"
  repo_name  = "umar-dev"
  team_name  = "form-builder"
  aws_region = "eu-west-2"
}

resource "kubernetes_secret" "umar-dev-ecr-credentials" {
  metadata {
    name      = "umar-dev-ecr-credentials-output"
    namespace = "umar-dev"
  }

  data {
    access_key_id     = "${module.umar-dev-ecr-credentials.access_key_id}"
    secret_access_key = "${module.umar-dev-ecr-credentials.secret_access_key}"
    repo_arn          = "${module.umar-dev-ecr-credentials.repo_arn}"
    repo_url          = "${module.umar-dev-ecr-credentials.repo_url}"
  }
}
