
    module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = var.eks_cluster_name
      service_account_name  = "${var.namespace-short}-athena"
      namespace             = var.namespace
      role_policy_arns = {
        athena = aws_iam_policy.athena_access.arn
      }

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
        resources = [
          "arn:aws:iam::396913731313:role/cmt_read_emds_data_test",
          "arn:aws:iam::800964199911:role/cmt_read_emds_data_dev",
        ]
      }
    }

    resource "aws_iam_policy" "athena_access" {
      name   = "${var.namespace}-athena-policy-general"
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
        name      = "${var.namespace}-irsa-output"
        namespace = var.namespace
      }
      data = {
        role = module.irsa.role_name
        serviceaccount = module.irsa.service_account.name
      }
    }