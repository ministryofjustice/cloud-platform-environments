module "dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.0.0"

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key          = "LockID"
  enable_encryption = "true"
  enable_autoscaler = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dynamodb" {
  metadata {
    name      = "dynamodb-table-output"
    namespace = var.namespace
  }

  data = {
    table_name = module.dynamodb.table_name
    table_arn  = module.dynamodb.table_arn
  }
}

resource "github_actions_variable" "dynamodb" {
  repository    = "hmpps-github-teams"
  variable_name = "TERRAFORM_DYNAMODB_TABLE_NAME"
  value         = module.dynamodb.table_name
}
