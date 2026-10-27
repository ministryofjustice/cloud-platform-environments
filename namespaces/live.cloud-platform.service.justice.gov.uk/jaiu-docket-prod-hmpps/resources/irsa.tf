/*
 * IAM Roles for Service Accounts (IRSA): how pods reach AWS resources on Cloud Platform.
 * See https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/accessing-aws-apis-and-resources-from-your-namespace.html
 *
 * This creates the `docket-api` Kubernetes service account with an IAM role that
 * holds the S3 bucket module's policy. The docket Helm chart runs its API and
 * worker pods under that service account (components.api.serviceAccount.create
 * = false, name = docket-api), and the AWS SDK inside them picks up credentials
 * from the injected AWS_ROLE_ARN / AWS_WEB_IDENTITY_TOKEN_FILE automatically.
 */
module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "docket-api"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
