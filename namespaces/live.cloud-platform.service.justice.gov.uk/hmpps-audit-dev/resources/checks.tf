check "approved_prisoner_clients_exist" {
    assert {
        condition = alltrue([
        for client in var.approved_prisoner_audit_clients :
        contains(keys(data.kubernetes_secret.approved_prisoner_audit_client_arns.data), client)
        ])
        error_message = "The approved client list does not match the keys in the approved_prisoner_audit_client_arns Kubernetes secret."
    }
}