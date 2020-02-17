module "jason-lab-rds-instance" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.0"

  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  application            = var.application
  environment-name       = var.environment-name
  is-production          = var.is-production
  infrastructure-support = var.infrastructure-support
  team_name              = var.team_name
  force_ssl              = "false"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "jason-lab-rds-instance" {
  metadata {
    name      = "jason-lab-${var.environment-name}"
    namespace = "jason-lab"
  }

  data = {
    # postgres://USER:PASSWORD@HOST:PORT/NAME
    url = "postgres://${module.jason-lab-rds-instance.database_username}:${module.jason-lab-rds-instance.database_password}@${module.jason-lab-rds-instance.rds_instance_endpoint}/${module.jason-lab-rds-instance.database_name}"
  }
}
resource "helm_release" "postgres_exporter" {
  name      = "postgres-exporter-namespace"
  chart     = "stable/prometheus-postgres-exporter"
  namespace = "jason-lab"
  values = [
    <<EOF
config:
  datasource:
    host: ${module.jason-lab-rds-instance.rds_instance_address}
    user: ${module.jason-lab-rds-instance.database_username}
    password: ${module.jason-lab-rds-instance.database_password}
    database:  ${module.jason-lab-rds-instance.database_name}
    sslmode: disable
rbac:
  pspEnabled: false
serviceMonitor:
  enabled: true
securityContext:
  runAsUser: 65534
EOF
  ]
  lifecycle {
    ignore_changes = [keyring]
  }
}
