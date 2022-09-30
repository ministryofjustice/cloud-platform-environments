resource "pingdom_check" "laa-crown-court-proceeding-dev" {
  type                     = "http"
  name                     = "LAA Crown Court Proceeding - Dev"
  host                     = "laa-crown-court-proceeding-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crown-court-proceeding,component_ping,isproduction_false,environment_dev,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}