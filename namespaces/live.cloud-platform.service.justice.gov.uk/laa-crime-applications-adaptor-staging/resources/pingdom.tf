resource "pingdom_check" "laa-crime-applications-adaptor-staging" {
  type                     = "http"
  name                     = "LAA Crime Applications Adaptor - Staging"
  host                     = "laa-crime-applications-adaptor-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-applications-adaptor,component_ping,isproduction_false,environment_staging,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}