# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-${var.environment}-hmpps_audit_queue" = "hmpps-audit-${var.environment}",
  }

  # The names of the SNS topics used and the namespace which created them
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-manage-and-deliver-accredited-programmes"

  role_policy_arns = merge(
    { elasticache = module.elasticache_redis.irsa_policy_arn },
    {
      sqs = module.hmpps_mandd_events_queue.irsa_policy_arn
    },
    {
      sqs_dlq = module.hmpps_mandd_events_dlq.irsa_policy_arn
    },
    local.sqs_policies,
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

module "irsa-cronjob" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "irsa-s3-cronjob"
  namespace            = var.namespace

  role_policy_arns = merge(
    {
      sqlserver_backup_s3_bucket_policy = module.sqlserver_backup_s3_bucket.irsa_policy_arn
    },
    {
      upload_s3_bucket_policy = module.upload_s3_bucket.irsa_policy_arn
    }
  )

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

/*module "irsa-sqlserver" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "irsa-sqlserver"
  namespace            = var.namespace

  role_policy_arns = merge(
    {
      sqlserver = module.sqlserver.irsa_policy_arn
    }
  )

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}*/
