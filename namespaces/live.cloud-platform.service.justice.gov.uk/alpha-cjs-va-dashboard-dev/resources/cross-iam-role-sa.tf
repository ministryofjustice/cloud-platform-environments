module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = var.eks_cluster_name
      namespace             = var.namespace
      service_account_name  = "${var.namespace}-sa2"
      role_policy_arns = { s3 = aws_iam_policy.alpha-cjs-va-dashboard-dev_ap_access_policy.arn }

      # Tags
      business_unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment_name       = var.environment
      infrastructure_support = var.infrastructure_support
    }
    data "aws_iam_policy_document" "alpha-cjs-va-dashboard-dev_ap_access_policy" {
      # Provide list of permissions and target AWS account resources to allow access to
      statement {
        actions = [
      "s3:ListBucket",
        ]
        resources = [
      "arn:aws:s3:::alpha-cjs-dataset-dip",
        ]
      }
      statement {
        actions = [
        "s3:GetObject",
        ]
        resources = [
        "arn:aws:s3:::alpha-cjs-dataset-dip/*"
        ]
      }
    }
    resource "aws_iam_policy" "alpha-cjs-va-dashboard-dev_ap_access_policy" {
      name   = "alpha-cjs-va-dashboard-dev_ap_access_policy"
      policy = data.aws_iam_policy_document.alpha-cjs-va-dashboard-dev_ap_access_policy.json

      tags = {
        business-unit          = var.business_unit
        application            = var.application
        is-production          = var.is_production
        environment-name       = var.environment
        owner                  = var.team_name
        infrastructure-support = var.infrastructure_support
      }
    }
    resource "kubernetes_secret" "irsa" {
      metadata {
        name      = "irsa-output"
        namespace = var.namespace
      }
      data = {
        role            = module.irsa.role_name
        serviceaccount  = module.irsa.service_account.name
        rolearn         = module.irsa.role_arn
      }
    }