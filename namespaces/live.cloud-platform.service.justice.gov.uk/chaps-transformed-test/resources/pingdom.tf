/*provider "pingdom" {
}*/

# Integration IDs
# 96624 = #dps_alerts

/*resource "pingdom_check" "chaps-transformed-aliveness-check" {
  type                     = "http"
  name                     = "Central Digital - CHAPS .NET8 Transformed Test"
  host                     = "service-standards-assurance.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hq,central-digital,cloudplatform-managed,cdpt"
  probefilters             = "region:EU"
  #integrationids           = []
}*/
