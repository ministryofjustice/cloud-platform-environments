variable "namespace" {
  description = "What is the name of your namespace? This should be of the form: <application>-<environment>. e.g. myapp-dev (lower-case letters and dashes only)"
  default     = "helloworld-dev"
}

variable "github_team" {
  description = "What is the name of your Github team? (this must be an exact match, or you will not have access to your namespace)"
  default     = "webops"
}

variable "business-unit" {
  description = "Which part of the MoJ is responsible for this service? (e.g HMPPS, Legal Aid Agency)"
  default     = "moj-digital"
}

variable "is-production" {
  description = "Is this a production namespace? (please answer true or false)"
  default     = "false"
}

variable "environment" {
  description = "What type of application environment is this namespace for? e.g. development, staging, production"
  default     = "dev"
}

variable "application" {
  description = "What is the name of your application/service? (e.g. Send money to a prisoner)"
  default     = "helloworld"
}

variable "owner" {
  description = "Which team in your organisation is responsible for this application? (e.g. Sentence Planning)"
  default     = "jason"
}

variable "contact_email" {
  description = "What is the email address for the team which owns the application? (this should not be a named individual's email address)"
  default     = "digital.justice.gov.uk"
}

variable "source_code_url" {
  description = "What is the Github repository URL of the source code for this application?"
  default     = "https://github.com/ministryofjustice/cloud-platform-helloworld-ruby-app"
}

# Variables for the gitops concourse pipeline


#variable "concourse_url" {}
#variable "concourse_basic_auth_username" {}
#variable "concourse_basic_auth_password" {}

