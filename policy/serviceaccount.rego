# Deny ServiceAccounts
package main

deny[msg] {
  input.kind == "ServiceAccount"
  msg := "ServiceAccount resources must be created via Terraform module - https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/main/main.tf"
}