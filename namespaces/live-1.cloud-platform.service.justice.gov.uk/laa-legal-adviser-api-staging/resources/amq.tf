module "amq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=2.1"

  cluster_name           = "${var.cluster_name}"
  cluster_state_bucket   = "${var.cluster_state_bucket}"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business-unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.email}"
}

resource "kubernetes_secret" "amq" {
  metadata {
    name      = "amq"
    namespace = "${var.namespace}"
  }

  data {
    primary_amqp_ssl_endpoint  = "${module.amq.primary_amqp_ssl_endpoint}"
    primary_stomp_ssl_endpoint = "${module.amq.primary_stomp_ssl_endpoint}"
    username                   = "${module.amq.username}"
    password                   = "${module.amq.password}"
  }
}
