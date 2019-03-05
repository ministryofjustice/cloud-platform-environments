variable "cluster" {
  description = "What cluster are you deploying your namespace. I.E cloud-platform-test-1 "
  default     = "cloud-platform-live-0"
}

variable "namespace" {
  description = "Namespace you would like to create on cluster <application>-<environment>. I.E myapp-dev"
  default     = "check-my-diary-dev"
}

variable "github_team" {
  description = "This is your team name as defined by the GITHUB api. This has to match the team name on the Github API"
  default     = "check-my-diary"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service"
  default     = "HMPPS"
}

variable "is-production" {
  default = "false"
}

variable "environment" {
  default = "dev"
}

variable "application" {
  default = "check-my-diary"
}

variable "owner" {
  description = "Who is the owner/Who is responsible for this application"
  default     = "Fareed Mohammed"
}

variable "contact_email" {
  description = "Contact email address for owner of the application"
  default     = "fareed.mohammed@digital.justice.gov.uk"
}

variable "source_code_url" {
  description = "Url of the source code for your application"
  default     = "git@github.com:ministryofjustice/check-my-diary.git"
}
