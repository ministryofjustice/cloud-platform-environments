provider "pingdom" {
}

resource "pingdom_check" "laa-manage-a-providers-data-staging" {
  type             = "http"
  name             = "Manage a providers data - staging - ping"
  host             = "laa-manage-a-providers-data-staging.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_manage-a-providers-data,component_ping,isproduction_false,environment_staging,infrastructuresupport_manage-a-providers-data,laa,manage-a-providers-data"
  probefilters     = "region:EU"
  integrationids   = [145169]
}
