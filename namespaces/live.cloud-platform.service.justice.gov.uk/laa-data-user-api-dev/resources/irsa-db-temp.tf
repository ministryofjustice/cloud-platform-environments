module "irsa-temp-db" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-laa-landing-page-${var.environment}"
  namespace            = var.namespace
  
  role_policy_arns = {
    rds-connect = aws_iam_policy.irsa_rds_connect.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  }

  data "aws_caller_identity" "current" {}

  data "aws_rds_instance" "rds_temp" {
    db_instance_identifier = "cloud-platform-3c2ab46b2dfd8d43"
  }

  resource "aws_iam_policy" "irsa_rds_connect" {
    name        = "irsa-${var.application}-${var.environment}-rds-db-connect"
    description = "Allow rds-db:connect to specific RDS instance for the application"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "rds-db:connect"
          Resource = "arn:aws:rds-db:eu-west-2:${data.aws_caller_identity.current.account_id}:dbuser:${data.rds_temp.resource_id}/${var.db_user_irsa}"
        }
      ]
    })
  }