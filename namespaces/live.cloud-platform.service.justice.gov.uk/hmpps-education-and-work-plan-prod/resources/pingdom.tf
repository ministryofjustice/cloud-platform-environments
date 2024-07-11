provider "pingdom" {
}

# Integration IDs
# 126338 = #farsight-alerts

resource "pingdom_check" "hmpps-education-and-work-plan-production-ui-check" {
	type                     = "http"
	name                     = "HMPPS - Education and Work Plan UI"
	host                     = "health-kick.prison.service.justice.gov.uk"
	resolution               = 1
	notifywhenbackup         = true
	sendnotificationwhendown = 6
	notifyagainevery         = 0
	url                      = "/https/learning-and-work-progress.hmpps.service.justice.gov.uk"
	encryption               = true
	port                     = 443
	tags                     = "businessunit_hmpps,application_education-and-work-plan-ui,component_front-end,isproduction_true,environment_prod"
	probefilters             = "region:EU"
	integrationids           = [126338]
}

resource "pingdom_check" "hmpps-education-and-work-plan-api-production-check" {
	type                     = "http"
	name                     = "HMPPS - Education and Work Plan API"
	host                     = "health-kick.prison.service.justice.gov.uk"
	resolution               = 1
	notifywhenbackup         = true
	sendnotificationwhendown = 6
	notifyagainevery         = 0
	url                      = "/https/learningandworkprogress-api.hmpps.service.justice.gov.uk"
	encryption               = true
	port                     = 443
	tags                     = "businessunit_hmpps,application_education-and-work-plan-api,component_api,isproduction_true,environment_prod"
	probefilters             = "region:EU"
	integrationids           = [126338]
}
