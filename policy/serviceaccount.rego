# Deny ServiceAccounts
package main
import rego.v1

deny[msg] if {
  input.kind == "ServiceAccount"
  msg := "ServiceAccount resources must be created via Terraform module - https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/main/main.tf"
}
