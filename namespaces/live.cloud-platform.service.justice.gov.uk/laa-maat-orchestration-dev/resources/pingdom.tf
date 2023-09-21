resource "pingdom_check" "laa-maat-orchestration-dev" {
  type                     = "http"
  name                     = "LAA Maat Orchestration - Dev"
  host                     = "laa-maat-orchestration-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-maat-orchestration,component_ping,isproduction_false,environment_dev,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}