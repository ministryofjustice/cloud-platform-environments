
    module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = var.eks_cluster_name
      namespace             = var.namespace
      service_account_name  = "${var.namespace}-athena-service-account"
      role_policy_arns = [aws_iam_policy.em_datastore_api_athena_general.arn]

      # Tags
      business_unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment_name       = var.environment
      infrastructure_support = var.infrastructure_support
    }

    data "aws_iam_policy_document" "document" {
      # Provide list of permissions and target AWS account resources to allow access to
      statement {
        actions = [
          "sts:AssumeRole"
        ]
        # This is a placeholder principal - waiting on real values before merging~
        principals {
          type        = "AWS"
          identifiers = ["arn:aws:iam::321388111150:role/BedrockAccessforCP"]
        }
      }
    }
    resource "aws_iam_policy" "em_datastore_api_athena_general" {
      name   = "em-datastore-api-athena-general-${var.namespace}"
      policy = data.aws_iam_policy_document.document.json

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
        role = module.irsa.aws_iam_role_name
        serviceaccount = module.irsa.service_account_name.name
      }
    }