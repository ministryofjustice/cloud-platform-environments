locals {
  github_app_rotated_date = "2026-05-21"
  github_app_repositories = [
    "community-api",
    "court-hearing-event-receiver",
    "crime-portal-gateway",
    "hmpps-appointment-reminders-ui",
    "hmpps-probation-integration-e2e-tests",
    "hmpps-probation-integration-services",
    "hmpps-supervision",
    "hmpps-tier",
    "hmpps-tier-ui",
    "ndelius-new-tech",
    "pdf-generator",
    "probation-offender-search",
    "probation-search-frontend",
    "probation-search-ui",
  ]
}

resource "null_resource" "rotation" {
  triggers = {
    rotation = local.github_app_rotated_date
  }
}

data "kubernetes_secret" "github_app" {
  metadata {
    name      = "github-app-probation-integration-bot"
    namespace = var.namespace
  }
}

resource "github_actions_secret" "app_id" {
  for_each        = toset(local.github_app_repositories)
  repository      = each.value
  secret_name     = "BOT_APP_ID"
  plaintext_value = data.kubernetes_secret.github_app.data.APP_ID
  lifecycle {
    replace_triggered_by = [null_resource.rotation]
  }
}

resource "github_actions_secret" "app_private_key" {
  for_each        = toset(local.github_app_repositories)
  repository      = each.value
  secret_name     = "BOT_APP_PRIVATE_KEY"
  plaintext_value = data.kubernetes_secret.github_app.data.PRIVATE_KEY
  lifecycle {
    replace_triggered_by = [null_resource.rotation]
  }
}

resource "github_dependabot_secret" "app_id" {
  for_each        = toset(local.github_app_repositories)
  repository      = each.value
  secret_name     = "BOT_APP_ID"
  plaintext_value = data.kubernetes_secret.github_app.data.APP_ID
  lifecycle {
    replace_triggered_by = [null_resource.rotation]
  }
}

resource "github_dependabot_secret" "app_private_key" {
  for_each        = toset(local.github_app_repositories)
  repository      = each.value
  secret_name     = "BOT_APP_PRIVATE_KEY"
  plaintext_value = data.kubernetes_secret.github_app.data.PRIVATE_KEY
  lifecycle {
    replace_triggered_by = [null_resource.rotation]
  }
}
