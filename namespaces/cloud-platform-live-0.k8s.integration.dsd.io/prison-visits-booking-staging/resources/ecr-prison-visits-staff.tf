module "ecr-repo-prison-visits-staff" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "prison-visits-booking"
  repo_name = "prison-visits-staff"
}

resource "kubernetes_secret" "ecr-repo-prison-visits-staff" {
  metadata {
    name      = "ecr-repo-prison-visits-staff"
    namespace = "prison-visits-booking-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-prison-visits-staff.repo_url}"
    access_key_id     = "${module.ecr-repo-prison-visits-staff.access_key_id}"
    secret_access_key = "${module.ecr-repo-prison-visits-staff.secret_access_key}"
  }
}
