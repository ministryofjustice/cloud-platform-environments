data "github_repository" "hmpps-probation-integration-services" {
  full_name = "ministryofjustice/hmpps-probation-integration-services"
}

data "github_actions_public_key" "hmpps-probation-integration-services" {
  repository = data.github_repository.hmpps-probation-integration-services.name
}