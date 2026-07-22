# irsa configuration is required to use the service pod
module "irsa_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  role_policy_arns = {
    # Here you must provide the policy arn(s) for the AWS resources you want to access via the service pod
    rds  = module.rds_mssql.irsa_policy_arn
    ecr = module.ecr.irsa_policy_arn
  }
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa_service_pod.service_account_name.name # this uses the service account name from the irsa module
}