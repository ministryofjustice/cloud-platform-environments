module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-arns-risk-actuarial-api"
  application = "hmpps-arns-risk-actuarial-api"
  github_team = "hmpps-assessments-devs"
  environment = var.environment
  is_production                 = var.is_production
<<<<<<< HEAD:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-prod/resources/arns-risk-actuarial-api.tf
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
=======
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
>>>>>>> f706173aa0f1e0b9ce10a95727a418e1523d5e62:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-preprod/resources/arns-risk-actuarial-api.tf
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
