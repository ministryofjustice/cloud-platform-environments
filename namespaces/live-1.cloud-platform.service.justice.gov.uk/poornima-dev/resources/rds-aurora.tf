

/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 *
 */

# variable "cluster_name" {
# }

# variable "cluster_state_bucket" {
# }

module "aurora_db" {
  source = "https://github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=main"

  team_name              = "cloud-platform"
  business-unit          = "Platforms"
  application            = "testapp-aurora"
  is-production          = "false"
  namespace              = "poornima-dev"
  environment-name       = "development"
  infrastructure-support = "platforms@digital.justice.gov.uk"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine
  engine = "aurora-postgresql"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_version
  engine_version = "9.6.9"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode
  # engine_mode            = "serverless"

  rds_name          = "poornima-dev-aurora-test"
  replica_count     = 1
  instance_type     = "db.r4.large"
  storage_encrypted = true
  apply_immediately = true

}


resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "cp-team-rds-cluster-output"
    namespace = "poornima-dev"
  }

  data = {
    rds_cluster_endpoint        = module.aurora_db.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.aurora_db.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.aurora_db.db_cluster_identifier
    database_name               = module.aurora_db.database_name
    database_username           = module.aurora_db.database_username
    database_password           = module.aurora_db.database_password
    access_key_id               = module.aurora_db.access_key_id
    secret_access_key           = module.aurora_db.secret_access_key
  }
}

