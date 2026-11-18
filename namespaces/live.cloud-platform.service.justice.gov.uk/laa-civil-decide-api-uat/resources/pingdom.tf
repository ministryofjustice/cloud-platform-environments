provider "pingdom" {
}

# Paused until the app's health-only ingress lets Pingdom past the LAA IP allowlist.
resource "pingdom_check" "laa-civil-decide-api-uat-pingdom" {
  type             = "http"
  name             = "${var.application} ${var.environment} - healthcheck"
  host             = "laa-civil-decide-api-uat.apps.live.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  url              = "/healthcheck"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.namespace},component_healthcheck,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters     = "region:EU"
  integrationids   = [149840]
  paused           = true
}
