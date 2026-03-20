# Service account for circleci
module "circleci-sa" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"
  serviceaccount_name = "circleci"
  role_name           = "circleci"
  rolebinding_name    = "circleci"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  github_repositories = ["hmpps-strengths-based-needs-assessments-ui", "hmpps-strengths-based-needs-assessments-api"]
  serviceaccount_token_rotated_date = "20-03-2026"
}