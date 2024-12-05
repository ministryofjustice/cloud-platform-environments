package main

test_deny_service_account {
    msg := "ServiceAccount resources must be created via Terraform module - https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/main/main.tf"

    service_account_object = {
        "apiVersion": "v1",
        "kind": "ServiceAccount",
        "metadata": {
            "name": "test-service-account",
            "namespace": "test-namespace"
        }
    }

    deny[msg] with input as service_account_object
}