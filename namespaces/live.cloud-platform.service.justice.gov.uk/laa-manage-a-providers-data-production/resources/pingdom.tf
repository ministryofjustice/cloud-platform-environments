provider "pingdom" {
}

resource "pingdom_check" "laa-manage-a-providers-data-production" {
  type             = "http"
  name             = "Manage a providers data - production - ping"
  host             = "laa-manage-a-providers-data.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_manage-a-providers-data,component_ping,isproduction_true,environment_production,infrastructuresupport_manage-a-providers-data,laa,manage-a-providers-data"
  probefilters     = "region:EU"
}
