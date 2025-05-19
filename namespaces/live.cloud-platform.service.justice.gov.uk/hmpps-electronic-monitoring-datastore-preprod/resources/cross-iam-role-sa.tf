    module "irsa" {
      source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
      eks_cluster_name      = var.eks_cluster_name
      service_account_name  = "${var.namespace-short}-athena"
      namespace             = var.namespace
      role_policy_arns = merge(
        local.sqs_policies,
        {
          athena = aws_iam_policy.athena_access.arn
          ssm = aws_iam_policy.ssm_access.arn
        }
      )

      # Tags
      business_unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment_name       = var.environment
      infrastructure_support = var.infrastructure_support
    }
