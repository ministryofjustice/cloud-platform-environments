module "crime_applications_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=3.2.0"

  team_name              = var.team_name
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace

  aws_region = var.dynamodb_aws_region

  # Unique key and sort attributes
  hash_key  = "id"
  range_key = "submitted_at"
}

resource "kubernetes_secret" "crime_applications_dynamodb" {
  metadata {
    name      = "crime-applications-dynamodb-output"
    namespace = var.namespace
  }

  data = {
    table_name        = module.crime_applications_dynamodb.table_name
    table_arn         = module.crime_applications_dynamodb.table_arn
    access_key_id     = module.crime_applications_dynamodb.access_key_id
    secret_access_key = module.crime_applications_dynamodb.secret_access_key

    # custom outputs
    aws_region = var.dynamodb_aws_region
  }
}
