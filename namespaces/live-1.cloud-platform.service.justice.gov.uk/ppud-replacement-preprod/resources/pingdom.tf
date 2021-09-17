resource "pingdom_check" "manage-recalls" {
  type                     = "http"
  name                     = "ppud-replacement - preprod - manage-recalls - cloud-platform"
  host                     = "manage-recalls-preprod.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,ppud-replacement,manage-recalls,preprod,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
}
