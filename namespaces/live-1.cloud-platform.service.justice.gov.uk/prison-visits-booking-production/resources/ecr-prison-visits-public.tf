module "ecr-repo-prison-visits-public" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=3.4"

  team_name = "${var.team_name}"
  repo_name = "prison-visits-public"
}

resource "kubernetes_secret" "ecr-repo-prison-visits-public" {
  metadata {
    name      = "ecr-repo-prison-visits-public"
    namespace = "${var.namespace}"
  }

  data {
    repo_url          = "${module.ecr-repo-prison-visits-public.repo_url}"
    access_key_id     = "${module.ecr-repo-prison-visits-public.access_key_id}"
    secret_access_key = "${module.ecr-repo-prison-visits-public.secret_access_key}"
  }
}
