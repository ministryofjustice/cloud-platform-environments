resource "pingdom_check" "manage-recalls" {
  type                     = "http"
  name                     = "ppud-replacement - prod - manage-recalls - cloud-platform"
  host                     = "manage-recalls.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,ppud-replacement,manage-recalls,prod,isproduction_true,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [116724]
}
