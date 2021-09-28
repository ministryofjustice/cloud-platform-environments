
module "dms_test_destination" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "dms-test-destination"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "dms_test_destination"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dms_test_destination" {
  metadata {
    name      = "dms-test-destination"
    namespace = var.namespace
  }

  data = {
    host     = module.dms_test_destination.rds_instance_address
    name     = module.dms_test_destination.database_name
    username = module.dms_test_destination.database_username
    password = module.dms_test_destination.database_password
  }
}

module "dms_test_source" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.5"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name             = "dms-test-source"
  rds_family           = "sqlserver-se-15.0"
  db_engine            = "sqlserver-se"
  db_engine_version    = "15.00"
  db_instance_class    = "db.t3.xlarge"
  db_allocated_storage = "32"
  license_model        = "license-included"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dms_test_source" {
  metadata {
    name      = "dms-test-source"
    namespace = var.namespace
  }

  data = {
    endpoint = module.dms_test_source.rds_instance_endpoint
    address  = module.dms_test_source.rds_instance_address
    username = module.dms_test_source.database_username
    password = module.dms_test_source.database_password
    name     = "dms-test-source"
  }
}
