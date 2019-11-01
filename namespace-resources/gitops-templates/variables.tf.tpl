variable "namespace" {
  description = "What is the name of your namespace? This should be of the form: <application>-<environment>. e.g. myapp-dev (lower-case letters and dashes only)"
  default = "${namespace}"
}

variable "github_team" {
  description = "What is the name of your Github team? (this must be an exact match, or you will not have access to your namespace)"
  default = "${github_team}"
}
