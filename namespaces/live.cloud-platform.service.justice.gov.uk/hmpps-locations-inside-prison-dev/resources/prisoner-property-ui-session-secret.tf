# Session secret for the hmpps-prisoner-property-ui frontend (Express session store).
# Consumed by the Helm chart's namespace_secrets as hmpps-prisoner-property-ui-session-secret -> SESSION_SECRET.
resource "random_password" "prisoner_property_ui_session_secret" {
  length  = 64
  special = false
}

resource "kubernetes_secret" "prisoner_property_ui_session_secret" {
  metadata {
    name      = "hmpps-prisoner-property-ui-session-secret"
    namespace = var.namespace
  }

  data = {
    SESSION_SECRET = random_password.prisoner_property_ui_session_secret.result
  }
}
