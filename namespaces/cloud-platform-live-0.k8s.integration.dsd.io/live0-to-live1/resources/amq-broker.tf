module "live0_to_live1_migration_broker" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-amq-broker?ref=1.0"
  team_name              = "${var.team_name}"
  business-unit          = "${var.business_unit}"
  application            = "${var.application}"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"
}

resource "kubernetes_secret" "live0_to_live1_migration_broker" {
  metadata {
    name      = "live0-to-live1-broker-output"
    namespace = "${var.namespace}"
  }

  data {
    primary_amqp_ssl_endpoint  = "${module.live0_to_live1_migration_broker.primary_amqp_ssl_endpoint}"
    primary_stomp_ssl_endpoint = "${module.live0_to_live1_migration_broker.primary_stomp_ssl_endpoint}"
    username                   = "${module.live0_to_live1_migration_broker.username}"
    password                   = "${module.live0_to_live1_migration_broker.password}"
  }
}
