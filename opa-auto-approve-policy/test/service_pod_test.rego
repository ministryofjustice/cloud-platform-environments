package test.terraform.analysis

import data.terraform.analysis

#########################
# Mock tf plan json file
#########################

mock_tfplan := {
	"variables": {"namespace": {"value": "testing-ns"}},
	"resource_changes": [
		{
			"address": "module.irsa_1.kubernetes_service_account.generated_sa",
			"module_address": "module.irsa_1",
			"type": "kubernetes_service_account",
			"name": "generated_sa",
			"change": {
				"actions": ["no-op"],
				"after": {"metadata": [{
					"name": "testing-sa-1",
					"namespace": "testing-ns",
				}]},
			},
		},
		{
			"address": "module.irsa_2.kubernetes_service_account.generated_sa",
			"module_address": "module.irsa_2",
			"type": "kubernetes_service_account",
			"name": "generated_sa",
			"change": {
				"actions": ["no-op"],
				"after": {"metadata": [{
					"name": "testing-sa-2",
					"namespace": "testing-ns",
				}]},
			},
		},
		{
			"address": "module.service_pod_1.kubernetes_deployment.service_pod",
			"module_address": "module.service_pod_1",
			"type": "kubernetes_deployment",
			"name": "service_pod",
			"change": {
				"actions": ["create"],
				"after": {
					"metadata": [{
						"name": "testing-sa-service-pod",
						"namespace": "testing-ns",
					}],
					"spec": [{"template": [{"spec": [{"service_account_name": "testing-sa-1"}]}]}],
				},
			},
		},
		{
			"address": "module.service_pod_2.kubernetes_deployment.service_pod",
			"module_address": "module.service_pod_2",
			"type": "kubernetes_deployment",
			"name": "service_pod",
			"change": {
				"actions": ["create"],
				"after": {
					"metadata": [{
						"name": "testing-sa-service-pod",
						"namespace": "testing-ns",
					}],
					"spec": [{"template": [{"spec": [{"service_account_name": "testing-sa-2"}]}]}],
				},
			},
		},
		{
			"address": "module.service_pod_1.random_id.name",
			"module_address": "module.service_pod_1",
			"mode": "managed",
			"type": "random_id",
			"name": "name",
			"provider_name": "registry.terraform.io/hashicorp/random",
			"change": {
				"actions": ["create"],
				"before": null,
				"after": {"byte_length": 8, "keepers": null, "prefix": null},
			},
		},
		{
			"address": "module.service_pod_2.random_id.name",
			"module_address": "module.service_pod_2",
			"mode": "managed",
			"type": "random_id",
			"name": "name",
			"provider_name": "registry.terraform.io/hashicorp/random",
			"change": {
				"actions": ["create"],
				"before": null,
				"after": {"byte_length": 8, "keepers": null, "prefix": null},
			},
		},
	],
}

#########################
# Test Cases
#########################

# Test: Allow rule passes when service pod and IRSA are valid
test_allow_if_valid_service_pod_and_irsa if {
	result := analysis.allow with input as mock_tfplan
	result == true
}

# Test: Deny if IAM policy changes are present
test_deny_if_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
	result == false
}

# Test: Deny if IAM policy attachment changes are present
test_deny_if_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
	result == false
}

# Test: Deny if namespace mismatch in service pod
test_deny_if_namespace_mismatch if {
	modified_plan := {
		"address": mock_tfplan.resource_changes[2].address,
		"type": mock_tfplan.resource_changes[2].type,
		"change": {
			"actions": ["create"],
			"after": {
				"metadata": [
					{"namespace": "testing-ns"},
					{"namespace": "invalid-namespace"},
				],
				"spec": [{"template": [{"spec": [{"service_account_name": "testing-sa-1"}]}]}],
			},
		},
	}

	result := analysis.allow with input as {
		"variables": mock_tfplan.variables,
		"resource_changes": [modified_plan, mock_tfplan.resource_changes[0]],
	}
	result == false
}

# Test: Deny if service pod references a non-existent IRSA account
test_deny_if_service_pod_irsa_mismatch if {
	modified_irsa := {
		"address": mock_tfplan.resource_changes[0].address,
		"type": mock_tfplan.resource_changes[0].type,
		"change": {
			"actions": ["no-op"],
			"after": {"metadata": [{"name": "non-existent-sa", "namespace": "testing-ns"}]},
		},
	}

	result := analysis.allow with input as {
		"variables": mock_tfplan.variables,
		"resource_changes": [mock_tfplan.resource_changes[2], modified_irsa],
	}
	result == false
}

# Test: Deny if involved other resource change
test_deny_if_involve_other_resource_change if {
	modified_plan := {
		"address": "aws_s3_bucket",
		"type": "aws_s3_bucket",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes[_]]}
	result == false
}

# Test: Deny if changes in IRSA
test_deny_if_irsa_change if {
	modified_irsa := {
		"address": mock_tfplan.resource_changes[0].address,
		"type": "kubernetes_service_account",
		"change": {
			"actions": ["update"],
			"after": {"metadata": [{"name": "testing-sa-1", "namespace": "testing-ns"}]},
		},
	}

	result := analysis.allow with input as {
		"variables": mock_tfplan.variables,
		"resource_changes": [mock_tfplan.resource_changes[2], modified_irsa],
	}
	result == false
}
