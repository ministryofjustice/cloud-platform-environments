module "test_aurora_creation" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-aurora?ref=1.6"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  allow_major_version_upgrade = "true"
  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine
  engine = "aurora-postgresql"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_version
  # engine_version         = "9.6.9"

  # https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/resources/rds_cluster#engine_mode
  # engine_mode            = "serverless"


  # If the rds_name is not specified a random name will be generated ( cloud-platform-* )
  # Changing the RDS name requires the RDS to be re-created (destroy + create)
  # rds_name               = "aurora-test"
  replica_count = 1
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance#instance_class
  # instance_type          = "db.r4.large"
  apply_immediately = true

}
resource "kubernetes_secret" "aurora_db" {
  metadata {
    name      = "example-team-rds-cluster-output"
    namespace = var.namespace
  }

  data = {
    rds_cluster_endpoint        = module.test_aurora_creation.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.test_aurora_creation.rds_cluster_reader_endpoint
    db_cluster_identifier       = module.test_aurora_creation.db_cluster_identifier
    database_name               = module.test_aurora_creation.database_name
    database_username           = module.test_aurora_creation.database_username
    database_password           = module.test_aurora_creation.database_password
    access_key_id               = module.test_aurora_creation.access_key_id
    secret_access_key           = module.test_aurora_creation.secret_access_key
  }
}
