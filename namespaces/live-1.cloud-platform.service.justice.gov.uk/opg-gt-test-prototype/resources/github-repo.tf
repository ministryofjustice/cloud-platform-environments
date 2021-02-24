data "github_team" "default" {
  slug = "gt-test-team"
}

locals {
  topics = ["gov-uk-prototype-kit", "moj-cloud-platform"]

  # These teams will be granted admin access to the github repository
  teams = {
    "default" : { id = data.github_team.default.id },
  }
}

# Repository basics
resource "github_repository" "prototype" {
  name                   = var.namespace
  description            = "Gov.UK Prototype Kit. This repository is defined and managed in Terraform"
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

  template {
    owner      = "ministryofjustice"
    repository = "moj-prototype-template"
  }

  lifecycle {
    ignore_changes = [template]
  }
}

resource "github_team_repository" "prototype" {
  for_each   = local.teams
  team_id    = each.value.id
  repository = github_repository.prototype.name
  permission = "admin"
}

resource "github_actions_secret" "prototype" {
  repository      = github_repository.prototype.name
  secret_name     = "PROTOTYPE_NAME"
  plaintext_value = var.namespace
}
