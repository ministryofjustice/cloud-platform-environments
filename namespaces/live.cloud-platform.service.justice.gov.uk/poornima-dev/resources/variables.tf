
variable "cluster_name" {
}

variable "kubernetes_cluster" {
}
variable "domain" {
  default = "dev-pk.service.justice.gov.uk"
}

variable "namespace" {
  default = "poornima-dev"
}

variable "application" {
  default = "test-app-poornima-dev"
}

variable "business-unit" {
  description = "MOJ Digital"
  default     = "mojdigital"
}

variable "team_name" {
  default     = "cloud-platform"
  description = "Cloud Platform"
}

variable "environment-name" {
  default     = "test"
  description = "Development/Test environment"
}

variable "infrastructure-support" {
  default     = "poornima.krishnasamy@digital.justice.gov.uk"
  description = "Cloud Platform"
}

variable "is-production" {
  default = "false"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}
