module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "15" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres15"
  db_instance_class = "db.t4g.micro"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false
  snapshot_identifier = "cloud-platform-47d4c6e80a73418c-pre-is-mig-test-2026-03-24"

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

module "copy" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "15" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres15"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-copy"
  snapshot_identifier = "temp-manual-snapshot-cloud-platform-47d4c6e80a73418c"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}



module "rds_with_is_migration" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "15" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres15"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-rds-with-is-migration"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false
  snapshot_identifier = "cloud-platform-47d4c6e80a73418c-pre-is-mig-test-2026-03-24"

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}




module "red" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.6" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-red"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

module "green" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.6" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-green"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}

module "blue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # RDS configuration
  allow_minor_version_upgrade  = true
  allow_major_version_upgrade  = false
  performance_insights_enabled = false
  db_max_allocated_storage     = "500"
  # enable_rds_auto_start_stop   = true # Uncomment to turn off your database overnight between 10PM and 6AM UTC / 11PM and 7AM BST.
  # db_password_rotated_date     = "2023-04-17" # Uncomment to rotate your database password.

  # PostgreSQL specifics
  db_engine         = "postgres"
  db_engine_version = "17.6" # If you are managing minor version updates, refer to user guide: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html#upgrading-a-database-version-or-changing-the-instance-type
  rds_family        = "postgres17"
  db_instance_class = "db.t4g.micro"
  rds_name          = "demo-dan1-blue"

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  # Testing RDS Restore
  deletion_protection = false

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for CLI queries,
  # uncomment below:

  # enable_irsa = true

  # If you want to enable Cloudwatch logging for this postgres RDS instance, uncomment the code below:
  # opt_in_xsiam_logging = true
}


resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
  }
  /* You can replace all of the above with the following, if you prefer to
     * use a single database URL value in your application code:
     *
     * url = "postgres://${module.rds.database_username}:${module.rds.database_password}@${module.rds.rds_instance_endpoint}/${module.rds.database_name}"
     *
     */
}

resource "kubernetes_secret" "copy" {
  metadata {
    name      = "rds-postgresql-instance-copy-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.copy.rds_instance_endpoint
    database_name         = module.copy.database_name
    database_username     = module.copy.database_username
    database_password     = module.copy.database_password
    rds_instance_address  = module.copy.rds_instance_address
  }
}

resource "kubernetes_secret" "rds_with_is_migration" {
  metadata {
    name      = "rds-postgresql-instance-rds-with-is-migration-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds_with_is_migration.rds_instance_endpoint
    database_name         = module.rds_with_is_migration.database_name
    database_username     = module.rds_with_is_migration.database_username
    database_password     = module.rds_with_is_migration.database_password
    rds_instance_address  = module.rds_with_is_migration.rds_instance_address
  }
}

resource "kubernetes_secret" "red" {
  metadata {
    name      = "rds-postgresql-instance-red-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.red.rds_instance_endpoint
    database_name         = module.red.database_name
    database_username     = module.red.database_username
    database_password     = module.red.database_password
    rds_instance_address  = module.red.rds_instance_address
  }
}

resource "kubernetes_secret" "green" {
  metadata {
    name      = "rds-postgresql-instance-green-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.green.rds_instance_endpoint
    database_name         = module.green.database_name
    database_username     = module.green.database_username
    database_password     = module.green.database_password
    rds_instance_address  = module.green.rds_instance_address
  }
}

resource "kubernetes_secret" "blue" {
  metadata {
    name      = "rds-postgresql-instance-blue-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.blue.rds_instance_endpoint
    database_name         = module.blue.database_name
    database_username     = module.blue.database_username
    database_password     = module.blue.database_password
    rds_instance_address  = module.blue.rds_instance_address
  }
}

# Configmap to store non-sensitive data related to the RDS instance

resource "kubernetes_config_map" "rds" {
  metadata {
    name      = "rds-postgresql-instance-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds.database_name
    db_identifier = module.rds.db_identifier
  }
}

resource "kubernetes_config_map" "copy" {
  metadata {
    name      = "rds-postgresql-instance-copy-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.copy.database_name
    db_identifier = module.copy.db_identifier
  }
}

resource "kubernetes_config_map" "rds_with_is_migration" {
  metadata {
    name      = "rds-postgresql-instance-rds-with-is-migration-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.rds_with_is_migration.database_name
    db_identifier = module.rds_with_is_migration.db_identifier
  }
}

resource "kubernetes_config_map" "red" {
  metadata {
    name      = "rds-postgresql-instance-red-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.red.database_name
    db_identifier = module.red.db_identifier
  }
}

resource "kubernetes_config_map" "green" {
  metadata {
    name      = "rds-postgresql-instance-green-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.green.database_name
    db_identifier = module.green.db_identifier
  }
}

resource "kubernetes_config_map" "blue" {
  metadata {
    name      = "rds-postgresql-instance-blue-output"
    namespace = var.namespace
  }

  data = {
    database_name = module.blue.database_name
    db_identifier = module.blue.db_identifier
  }
}
