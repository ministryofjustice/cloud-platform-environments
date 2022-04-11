provider "pingdom" {
}

resource "pingdom_check" "laa-crime-means-assessment-test" {
  type                     = "http"
  name                     = "LAA Crime Means Assessment - Test"
  host                     = "test.laa-crime-means-assessment.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 8096
  tags                     = "businessunit_laa,application_laa-crime-means-assessment,component_ping,isproduction_false,environment_test,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}