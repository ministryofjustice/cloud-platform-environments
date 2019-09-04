# HMCTS Complaints Adapter ECR Repos
module "ecr-repo-hmcts-complaints-adapter" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "${var.team_name}"
  repo_name = "hmcts-complaints-formbuilder-adapter"
}

resource "kubernetes_secret" "ecr-repo-hmcts-complaints-adapter" {
  metadata {
    name      = "ecr-repo-hmcts-complaints-adapter"
    namespace = "hmcts-complaints-formbuilder-adapter-${var.environment-name}"
  }

  data {
    repo_url          = "${module.ecr-repo-hmcts-complaints-adapter.repo_url}"
    access_key_id     = "${module.ecr-repo-hmcts-complaints-adapter.access_key_id}"
    secret_access_key = "${module.ecr-repo-hmcts-complaints-adapter.secret_access_key}"
  }
}
