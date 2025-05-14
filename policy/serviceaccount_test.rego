package main
import future.keywords.if

test_deny_service_account if {
    msg := "ServiceAccount resources must be created via Terraform module - https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/main/main.tf"

    service_account_object = {
        "apiVersion": "v1",
        "kind": "ServiceAccount",
        "metadata": {
            "name": "test-service-account",
            "namespace": "test-namespace"
        }
    }

    deny_serviceaccount[msg] with input as service_account_object
}
