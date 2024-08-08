
    module "cross-irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = "var.eks_cluster_name"
      namespace             = "var.namespace"
      service_account_name  = "${var.team_name}-${var.environment}"
      role_policy_arns = ["aws_iam_policy.hmpps_subject_access_request_dev_aws_policy.arn"]
      # Tags
      business_unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment_name       = var.environment
      infrastructure_support = var.infrastructure_support
    }
    data "aws_iam_policy_document" "hmpps_subject_access_request_dev_aws_policy" {
      # Provide list of permissions and target AWS account resources to allow access to
      statement {
        actions = [
          "apigateway:POST",
        ]
        resources = [
          "<ARN of resource in target AWS account>/*",
        ]
      }
    }
    resource "aws_iam_policy" "hmpps_subject_access_request_dev_aws_policy" {
      name   = "hmpps_subject_access_request_dev_aws_policy"
      policy = data.aws_iam_policy_document.hmpps_subject_access_request_dev_aws_policy.json

      tags = {
        business-unit          = "var.business_unit"
        application            = "var.application"
        is-production          = "var.is_production"
        environment-name       = "var.environment"
        owner                  = "var.team_name"
        infrastructure-support = "var.infrastructure_support"
      }
    }
    resource "kubernetes_secret_cross" "irsa" {
      metadata {
        name      = "irsa-output"
        namespace = "var.namespace"
      }
      data = {
        role = module.cross-irsa.aws_iam_role_name
        serviceaccount = module.cross-irsa.service_account_name.name
      }
    }
