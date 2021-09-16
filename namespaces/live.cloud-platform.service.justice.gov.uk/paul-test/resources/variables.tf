variable "kubernetes_cluster" {
}
variable "namespace" {
  default = "paul-test"
}
variable "serviceaccount_name" {
  default = "paul-test"
}
variable "service_account" {
  default     = "paul-test"
  description = "service account"
}
