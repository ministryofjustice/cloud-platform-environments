module "visit_scheduler_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "17.4"
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.micro"
  db_max_allocated_storage    = "500"
  db_password_rotated_date    = "2023-03-22"

  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "visit_scheduler_rds" {
  metadata {
    name      = "visit-scheduler-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.visit_scheduler_rds.rds_instance_endpoint
    database_name         = module.visit_scheduler_rds.database_name
    database_username     = module.visit_scheduler_rds.database_username
    database_password     = module.visit_scheduler_rds.database_password
    rds_instance_address  = module.visit_scheduler_rds.rds_instance_address
  }
}

module "prison_visit_booker_registry_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  prepare_for_major_upgrade   = true
  db_engine                   = "postgres"
  db_engine_version           = "17.4"
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.small"
  db_max_allocated_storage    = "500"
  db_password_rotated_date    = "2023-03-22"

  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "prison_visit_booker_registry_rds" {
  metadata {
    name      = "prison-visit-booker-registry-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.prison_visit_booker_registry_rds.rds_instance_endpoint
    database_name         = module.prison_visit_booker_registry_rds.database_name
    database_username     = module.prison_visit_booker_registry_rds.database_username
    database_password     = module.prison_visit_booker_registry_rds.database_password
    rds_instance_address  = module.prison_visit_booker_registry_rds.rds_instance_address
  }
}

module "visit_allocation_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  allow_major_version_upgrade = "false"
  allow_minor_version_upgrade = "true"
  prepare_for_major_upgrade   = false
  db_engine                   = "postgres"
  db_engine_version           = "17.4"
  rds_family                  = "postgres17"
  db_instance_class           = "db.t4g.small"
  enable_rds_auto_start_stop   = true
  performance_insights_enabled = true

  providers = {
    aws = aws.london
  }

  enable_irsa = true
}

resource "kubernetes_secret" "visit_allocation_rds" {
  metadata {
    name      = "visit-allocation-rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.visit_allocation_rds.rds_instance_endpoint
    database_name         = module.visit_allocation_rds.database_name
    database_username     = module.visit_allocation_rds.database_username
    database_password     = module.visit_allocation_rds.database_password
    rds_instance_address  = module.visit_allocation_rds.rds_instance_address
  }
}
