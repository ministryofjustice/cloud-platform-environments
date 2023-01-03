resource "pingdom_check" "laa-crown-court-proceeding-staging" {
  type                     = "http"
  name                     = "LAA Crown Court Proceeding - Staging"
  host                     = "laa-crown-court-proceeding-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crown-court-proceeding,component_ping,isproduction_false,environment_staging,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}