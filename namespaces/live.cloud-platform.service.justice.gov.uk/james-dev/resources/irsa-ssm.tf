# name        = "/application_insights/key-preprod"
# name        = "/application_insights/key-dev"
# name        = "/application_insights/key-prod"

data "aws_ssm_parameter" "key_dev" {
  name = "/application_insights/key-dev"
}

data "aws_ssm_parameter" "key_preprod" {
  name = "/application_insights/key-preprod"
}

data "aws_ssm_parameter" "key_prod" {
  name = "/application_insights/key-prod"
}

data "aws_iam_policy_document" "ssm_for_insights" {
  version = "2012-10-17"
      
      statement {
        sid     = "AllowSecretsManagerGetPutValue"
        effect  = "Allow"
        actions = [
          "ssm:GetParameter",
          "ssm:PutParameter"
        ]
      resources = [
        data.aws_ssm_parameter.key_preprod.arn,
        data.aws_ssm_parameter.key_dev.arn,
        data.aws_ssm_parameter.key_prod.arn 
        ]
      }
    }

resource "aws_iam_policy" "policy" {
  name        = "app_insights_ssm_policy"
  description = "Policy for app insights"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.ssm_for_insights.json
}


module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "james-dev-irsa"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
   ssm = aws_iam_policy.policy.arn
  }
  
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-sre"
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}