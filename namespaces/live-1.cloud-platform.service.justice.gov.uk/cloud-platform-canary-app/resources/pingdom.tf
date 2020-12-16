resource "pingdom_check" "cloud-platform-canary" {
  type                     = "http"
  name                     = "cloud-platform monitoring canary"
  host                     = "canary.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [90339]
}

