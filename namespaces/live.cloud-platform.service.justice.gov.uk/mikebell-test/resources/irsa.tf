# module "irsa" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

#   # EKS configuration
#   eks_cluster_name = var.eks_cluster_name

#   service_account_name = "${var.team_name}-${var.environment}"
#   role_policy_arns = {
#     rds = module.rds.irsa_policy_arn
#   }

#   # Tags
#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace # this is also used to attach your service account to your namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }

# module "service_pod" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release

#   # Configuration
#   namespace            = var.namespace
#   service_account_name = module.irsa.service_account.name
# }
