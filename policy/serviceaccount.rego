# Deny ServiceAccounts
package main
import future.keywords.if

deny_serviceaccount[msg] {
  input.kind == "ServiceAccount"
  msg := "ServiceAccount resources must be created via Terraform module - https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/main/main.tf"
}
