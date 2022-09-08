data "github_team" "default" {
  slug = "manage-a-workforce"
}

locals {
  topics = ["gov-uk-design-history", "moj-cloud-platform"]

  # These teams will be granted admin access to the github repository
  teams = {
    "default" : { id = data.github_team.default.id },
  }
}

# Repository basics
resource "github_repository" "design_history" {
  name                   = "manage-a-workforce-design-history"
  description            = "A place for you to document your GOV.UK service designs"
  visibility             = "public"
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  has_downloads          = false
  is_template            = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  auto_init              = false
  archived               = false
  vulnerability_alerts   = true
  topics                 = local.topics

}

resource "github_team_repository" "design_history" {
  for_each   = local.teams
  team_id    = each.value.id
  repository = github_repository.design_history.name
  permission = "admin"
}

resource "github_actions_secret" "design_history" {
  repository      = github_repository.design_history.name
  secret_name     = "PROTOTYPE_NAME"
  plaintext_value = var.namespace
}
