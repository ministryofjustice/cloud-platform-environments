resource "pingdom_check" "laa-crown-court-contribution-prod" {
  type                     = "http"
  name                     = "LAA Crown Court Contribution - PROD"
  host                     = "laa-crown-court-contribution-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crown-court-contribution,component_ping,isproduction_true,environment_prod,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}

