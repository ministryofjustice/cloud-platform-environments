
variable "cluster_name" {
}

variable "kubernetes_cluster" {
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "DSO Monitoring"
}

variable "namespace" {
  default = "dso-monitoring-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "studio-webops"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "digital-studio-operations-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "dso_internal"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

variable "mp_account" {
  description = "Destination account for metrics collection"
  default     = "272983201692" # nomis-production
}

variable "grafana_sa" {
  description = "Name for Grafana service account"
  default     = "grafana-prod"
}

variable "prometheus_sa" {
  description = "Name for Prometheus service account"
  default     = "prometheus-server-prod"
}

variable "alertmanager_sa" {
  description = "Name for Alertmanager service account"
  default     = "prometheus-alertmanager-prod"
}