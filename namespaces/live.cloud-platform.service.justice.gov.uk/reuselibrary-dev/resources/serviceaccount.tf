module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.7"

  namespace           = var.namespace                  # e.g. "reuselibrary-dev"
  kubernetes_cluster  = var.kubernetes_cluster         # e.g. "live"

  # Set this to the date you want to rotate the token (dd-mm-yyyy)
  serviceaccount_token_rotated_date = "02-09-2026"

  serviceaccount_name = "github-actions"
  owner               = "reuse-library@justice.gov.uk"

  # Creates repo-level secrets (ca.crt / token / server)
  github_repositories = ["ministryofjustice/reuse-library"]

  # Optional: also create environment-scoped secrets
  github_environments = ["dev"]
}
