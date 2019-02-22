module "ecr-repo-prison-visits-booking" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=1.0"

  team_name = "prison-visits-booking"
  repo_name = "prison-visits-booking"
}

resource "kubernetes_secret" "ecr-repo-prison-visits-booking" {
  metadata {
    name      = "ecr-repo-prison-visits-booking"
    namespace = "prison-visits-booking-staging"
  }

  data {
    repo_url          = "${module.ecr-repo-prison-visits-booking.repo_url}"
    access_key_id     = "${module.ecr-repo-prison-visits-booking.access_key_id}"
    secret_access_key = "${module.ecr-repo-prison-visits-booking.secret_access_key}"
  }
}
