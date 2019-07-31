terraform {
   backend "s3" {}
 }

 provider "pingdom" {}

 resource "pingdom_check" "prison-visits-booking-public-production" {
    type                     = "http"
    name                     = "Prison Visits Public - production - cloud-platform - Healthcheck"
    host                     = "prisonvisits.service.gov.uk"
    resolution               = 1
    notifywhenbackup         = true
    sendnotificationwhendown = 6
    notifyagainevery         = 0
    url                      = "/healthcheck"
    encryption               = true
    port                     = 443
    tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_platforms"
    probefilters             = "region:EU"
    publicreport             = "true"
    integrationids           = [94618]
  }
