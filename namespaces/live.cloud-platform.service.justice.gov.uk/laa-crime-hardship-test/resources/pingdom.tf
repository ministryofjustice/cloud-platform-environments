resource "pingdom_check" "laa-crime-hardship-test" {
  type                     = "http"
  name                     = "LAA Crime Hardship - Test"
  host                     = "laa-crime-hardship-test.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-hardship,component_ping,isproduction_false,environment_test,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}