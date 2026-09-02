# Registers "hmpps-digital-prison-reporting-mi" with GitHub Actions for the
# "dev" environment (track 1 / main API). Creates the GitHub Environment,
# a dedicated Kubernetes service account in this namespace, and pushes
# KUBE_CERT/KUBE_CLUSTER/KUBE_NAMESPACE/KUBE_TOKEN into that environment's
# secrets (with weekly rotation). No reviewer_teams set here deliberately -
# dev has no approval gate, matching the previous CircleCI behaviour.
#
# Scoped to this namespace only, per Cloud Platform's one-namespace-per-PR
# convention. Track 2 (probation-dev, in the hmpps-probation-mi-ui-dev
# namespace) and test/preprod/prod are added as separate follow-up PRs.
module "hmpps_digital_prison_reporting_mi_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"

  github_repo                   = "hmpps-digital-prison-reporting-mi"
  application                   = "hmpps-digital-prison-reporting-mi"
  github_team                   = var.team_name
  environment                   = "dev" # must match pipeline `environment:` and helm_deploy/values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "dev" # "dev", "preprod" or "prod"
  selected_branch_patterns      = ["main"]
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
