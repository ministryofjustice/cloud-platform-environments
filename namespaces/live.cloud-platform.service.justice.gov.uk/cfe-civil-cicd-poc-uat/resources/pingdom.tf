provider "pingdom" {
}

resource "pingdom_check" "cfe-civil-cicd-poc-uat" {
  type                     = "http"
  name                     = "Eligibility Platform - CFE Civil CICD POC UAT - ping"
  host                     = "main-cfe-civil-cicd-poc-uat.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [128662]
}