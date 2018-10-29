##################################################

# User Datastore ECR Repos
module "ecr-repo-fb-runner-node" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "${var.team_name}"
  repo_name = "fb-runner-node"
}

resource "kubernetes_secret" "ecr-repo-fb-runner-node" {
  metadata {
    name      = "ecr-repo-fb-runner-node"
    namespace = "formbuilder-platform-dev"
  }

  data {
    repo_url          = "${module.ecr-repo-fb-runner-node.repo_url}"
    access_key_id     = "${module.ecr-repo-fb-runner-node.access_key_id}"
    secret_access_key = "${module.ecr-repo-fb-runner-node.secret_access_key}"
  }
}
