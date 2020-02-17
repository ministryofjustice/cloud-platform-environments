/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "cp_team_test_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.0"
  cluster_name           = var.cluster_name
  cluster_state_bucket   = var.cluster_state_bucket
  team_name              = "cp-team-test-repo"
  business-unit          = "cp-team-test-bu"
  application            = "cpteamtestapp"
  is-production          = "false"
  environment-name       = "development"
  infrastructure-support = "poornima.krishnasamy@digital.justice.gov.uk"
  force_ssl              = "false"

  # use "allow_major_version_upgrade" when upgrading the major version of an engine
  allow_major_version_upgrade = "true"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "cp_team_test_rds" {
  metadata {
    name      = "cp-team-test-rds-instance-output"
    namespace = "poornima-dev"
  }

  data = {
    url = "postgres://${module.cp_team_test_rds.database_username}:${module.cp_team_test_rds.database_password}@${module.cp_team_test_rds.rds_instance_endpoint}/${module.cp_team_test_rds.database_name}"
  }
}
resource "helm_release" "postgres_exporter" {
  name      = "postgres-exporter"
  chart     = "stable/prometheus-postgres-exporter"
  namespace = "poornima-dev"
  values = [
    <<EOF
config:
  datasource:
    host: ${module.cp_team_test_rds.rds_instance_address}
    user: ${module.cp_team_test_rds.database_username}
    password: ${module.cp_team_test_rds.database_password}
    database:  ${module.cp_team_test_rds.database_name}
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
