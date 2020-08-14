provider "pingdom" {
}

#
# CMS check
#
resource "pingdom_check" "prisoner-content-hub-production-checks-drupal-cms" {

  name = "Prisoner Content Hub Production – Drupal CMS"
  host = "manage.content-hub.prisoner.service.justice.gov.uk"

  type                     = "http"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307, # #pfs_dev channel
    106310, # #pfs_alerts channel
  ]
}

#
# Prison frontend checks
#

resource "pingdom_check" "prisoner-content-hub-production-checks-berwyn" {

  name = "Prisoner Content Hub Production – Berwyn"
  host = "berwyn.content-hub.prisoner.service.justice.gov.uk"

  type                     = "http"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307, # #pfs_dev channel
    106310, # #pfs_alerts channel
  ]
}

resource "pingdom_check" "prisoner-content-hub-production-checks-cookhamwood" {

  name = "Prisoner Content Hub Production – Cookham Wood"
  host = "cookhamwood.content-hub.prisoner.service.justice.gov.uk"

  type                     = "http"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307, # #pfs_dev channel
    106310, # #pfs_alerts channel
  ]
}

resource "pingdom_check" "prisoner-content-hub-production-checks-wayland" {

  name = "Prisoner Content Hub Production – Wayland"
  host = "wayland.content-hub.prisoner.service.justice.gov.uk"

  type                     = "http"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_healthcheck,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  publicreport             = "true"

  integrationids = [
    106307, # #pfs_dev channel
    106310, # #pfs_alerts channel
  ]
}

