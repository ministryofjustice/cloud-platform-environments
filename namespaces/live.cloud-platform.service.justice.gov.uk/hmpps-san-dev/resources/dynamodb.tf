module "hmpps_san_info_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = "san-health-ping-info"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key       = "service_environment"
  hash_key_type  = "S"
  range_key      = "recorded_at_epoch"
  range_key_type = "N"

  enable_encryption = "true"
  enable_autoscaler = "true"

  providers = {
    aws = aws.london
  }
}

module "hmpps_san_health_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = "san-health-ping-health"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key       = "service_environment"
  hash_key_type  = "S"
  range_key      = "recorded_at_epoch"
  range_key_type = "N"

  enable_encryption = "true"
  enable_autoscaler = "true"

  providers = {
    aws = aws.london
  }
}

module "hmpps_san_version_dynamodb" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster?ref=4.1.0"

  team_name              = var.team_name
  application            = "san-health-ping-version"
  business_unit          = var.business_unit
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace

  hash_key       = "service_environment"
  hash_key_type  = "S"
  range_key      = "recorded_at_epoch"
  range_key_type = "N"

  enable_encryption = "true"
  enable_autoscaler = "true"

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps_san_health_ping_dynamodb_dml" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:TransactGetItems",
      "dynamodb:TransactWriteItems",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]

    resources = [
      module.hmpps_san_info_dynamodb.table_arn,
      "${module.hmpps_san_info_dynamodb.table_arn}/index/*",
      module.hmpps_san_health_dynamodb.table_arn,
      "${module.hmpps_san_health_dynamodb.table_arn}/index/*",
      module.hmpps_san_version_dynamodb.table_arn,
      "${module.hmpps_san_version_dynamodb.table_arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "hmpps_san_health_ping_dynamodb_dml" {
  name        = "${var.namespace}-san-health-ping-dynamodb-dml"
  description = "DML access for san-health-ping to san DynamoDB tables"
  policy      = data.aws_iam_policy_document.hmpps_san_health_ping_dynamodb_dml.json
}

resource "kubernetes_secret" "hmpps_san_dynamodb" {
  metadata {
    name      = "hmpps-san-dynamodb"
    namespace = var.namespace
  }

  data = {
    info_table_name    = module.hmpps_san_info_dynamodb.table_name
    info_table_arn     = module.hmpps_san_info_dynamodb.table_arn
    health_table_name  = module.hmpps_san_health_dynamodb.table_name
    health_table_arn   = module.hmpps_san_health_dynamodb.table_arn
    version_table_name = module.hmpps_san_version_dynamodb.table_name
    version_table_arn  = module.hmpps_san_version_dynamodb.table_arn
  }
}

module "hmpps_san_health_ping_dynamodb_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "san-health-ping"

  role_policy_arns = {
    hmpps_san_health_ping_dynamodb_dml = aws_iam_policy.hmpps_san_health_ping_dynamodb_dml.arn
  }

  business_unit          = var.business_unit
  application            = "san-health-ping"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
