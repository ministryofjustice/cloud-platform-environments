resource "pingdom_check" "laa-dces-drc-integration-dev" {
  type                     = "http"
  name                     = "LAA DCES DRC Integration - Dev"
  host                     = "laa-dces-drc-integration-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-dces-drc-integration,component_ping,isproduction_false,environment_dev,owner_laa-dces-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}