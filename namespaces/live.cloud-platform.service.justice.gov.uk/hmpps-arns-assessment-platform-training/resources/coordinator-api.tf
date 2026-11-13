module "hmpps_assess_risks_and_needs_coordinator_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-assess-risks-and-needs-coordinator-api"
  application                   = "hmpps-assess-risks-and-needs-coordinator-api"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  selected_branch_patterns      = ["*"]
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

# The chart reads one secret named after the application. The template module only creates
# <application>-application-insights and <application>-client-creds, so this secret is added here.
# Placeholders follow the module's client credential secrets: "example value", never overwritten by terraform.
resource "kubernetes_secret" "coordinator_api" {
  metadata {
    name      = module.hmpps_assess_risks_and_needs_coordinator_api.application
    namespace = var.namespace
    annotations = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.aws_ssm_parameter.application_insights_key.value
    COORDINATOR_CLIENT_ID          = "example value"
    COORDINATOR_CLIENT_SECRET      = "example value"
  }

  lifecycle {
    ignore_changes = [data]
  }
}

module "coordinator_api_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=9.2.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  db_name = var.coordinator_db_name

  # Postgres 18 matches the coordinator docker-compose and the integrations test namespace
  rds_family        = "postgres18"
  db_instance_class = "db.t4g.micro"
  db_engine         = "postgres"
  db_engine_version = "18.6"

  allow_major_version_upgrade = false
  prepare_for_major_upgrade   = false

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "coordinator_api_rds" {
  metadata {
    name      = "hmpps-assess-risks-and-needs-integrations-rds-instance"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.coordinator_api_rds.rds_instance_endpoint
    database_name         = module.coordinator_api_rds.database_name
    database_username     = module.coordinator_api_rds.database_username
    database_password     = module.coordinator_api_rds.database_password
    rds_instance_address  = module.coordinator_api_rds.rds_instance_address
  }
}

module "arns_coordinator_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "arns_coordinator_queue"
  encrypt_sqs_kms            = true
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.arns_coordinator_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "arns_coordinator_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "arns_coordinator_dlq"
  encrypt_sqs_kms = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "arns_coordinator_queue" {
  metadata {
    name      = "sqs-arns-coordinator-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.arns_coordinator_queue.sqs_id
    sqs_queue_arn  = module.arns_coordinator_queue.sqs_arn
    sqs_queue_name = module.arns_coordinator_queue.sqs_name
  }
}

resource "kubernetes_secret" "arns_coordinator_dead_letter_queue" {
  metadata {
    name      = "sqs-arns-coordinator-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.arns_coordinator_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.arns_coordinator_dead_letter_queue.sqs_arn
    sqs_queue_name = module.arns_coordinator_dead_letter_queue.sqs_name
  }
}
