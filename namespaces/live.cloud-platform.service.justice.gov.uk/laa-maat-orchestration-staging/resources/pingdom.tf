resource "pingdom_check" "laa-maat-orchestration-staging" {
  type                     = "http"
  name                     = "LAA Maat Orchestration - Staging"
  host                     = "laa-maat-orchestration-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-maat-orchestration,component_ping,isproduction_false,environment_staging,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}