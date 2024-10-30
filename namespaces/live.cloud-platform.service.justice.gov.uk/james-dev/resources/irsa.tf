# irsa configuration is required to use the service pod
module "irsa" {
  role_policy_arns = {
  # Here you must provide the policy arn(s) for the AWS resources you want to access via the service pod
  ssm  = module.ssm.irsa_policy_arn
  }
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.1.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}