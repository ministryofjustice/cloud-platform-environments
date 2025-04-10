resource "github_repository_environment" "env" {
  environment = "dev"
  repository  = "mikebell-test"

  #   reviewers {
  #     teams = [for team in data.github_team.teams : team.id]
  #   }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }

  # prevent_self_review = false

  # lifecycle {
  #   precondition {
  #     condition     = var.is_production == "true" ? length(var.reviewer_teams) > 0 : true
  #     error_message = "Reviewer teams must be specified for production environments."
  #   }
  # }
}

resource "github_repository_environment" "env" {
  environment = "prod"
  repository  = "mikebell-test"

  #   reviewers {
  #     teams = [for team in data.github_team.teams : team.id]
  #   }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }

  # prevent_self_review = false

  # lifecycle {
  #   precondition {
  #     condition     = var.is_production == "true" ? length(var.reviewer_teams) > 0 : true
  #     error_message = "Reviewer teams must be specified for production environments."
  #   }
  # }
}
