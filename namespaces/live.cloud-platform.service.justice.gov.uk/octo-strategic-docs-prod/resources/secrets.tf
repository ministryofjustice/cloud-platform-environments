## Entra ID / oauth2-proxy secrets
##
## This creates *empty* placeholder secrets in AWS Secrets Manager,
## synced into Kubernetes secrets in this namespace. The actual secret
## values (client-id, client-secret, tenant-id, cookie-secret) are NOT
## managed by Terraform/committed to git - they must be populated
## directly into AWS Secrets Manager out-of-band by a namespace admin,
## after this resource has been applied. See the Entra app
## registration at ministryofjustice/staff-identity-idam-entra-infra#702
## for the client-id/tenant-id, and generate a client secret via the
## Entra admin center's "Certificates & secrets" blade.
module "secrets_manager_multiple_secrets" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.7"

  # Use the aliased "london" provider so the created secrets inherit the
  # GithubTeam default tag, which is required for our team to be able to
  # view/set the secret values via the AWS console.
  providers = {
    aws = aws.london
  }

  team_name              = var.team_name
  application            = var.application
  business_unit          = var.business_unit
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name

  secrets = {
    "entra-oauth2-proxy" = {
      description             = "Entra ID OAuth2 client details for oauth2-proxy (client-id, client-secret, tenant-id)"
      recovery_window_in_days = 0
      k8s_secret_name         = "entra-oauth2-proxy"
    },
    "oauth2-proxy-cookie-secret" = {
      description             = "oauth2-proxy cookie signing secret"
      recovery_window_in_days = 0
      k8s_secret_name         = "oauth2-proxy-cookie-secret"
    },
  }
}
