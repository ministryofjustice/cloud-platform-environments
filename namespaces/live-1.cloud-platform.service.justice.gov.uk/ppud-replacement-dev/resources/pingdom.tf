resource "pingdom_check" "manage-recalls" {
  type                     = "http"
  name                     = "ppud-replacement - dev - manage-recalls - cloud-platform"
  host                     = "manage-recalls-dev.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,ppud-replacement,manage-recalls,dev,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [116726]
}
