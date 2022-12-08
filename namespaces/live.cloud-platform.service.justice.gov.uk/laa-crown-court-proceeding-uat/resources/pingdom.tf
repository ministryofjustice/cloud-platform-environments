resource "pingdom_check" "laa-crown-court-proceeding-uat" {
  type                     = "http"
  name                     = "LAA Crown Court Proceeding - Uat"
  host                     = "laa-crown-court-proceeding-uat.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crown-court-proceeding,component_ping,isproduction_false,environment_uat,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}