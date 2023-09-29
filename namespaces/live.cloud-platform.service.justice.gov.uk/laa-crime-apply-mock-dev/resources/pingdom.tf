resource "pingdom_check" "laa-crime-apply-mock-api-dev" {
  type                     = "http"
  name                     = "LAA Crime Apply Mock API - Dev"
  host                     = "laa-crime-apply-mock-api-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-apply-mock-api,component_ping,isproduction_false,environment_dev,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}