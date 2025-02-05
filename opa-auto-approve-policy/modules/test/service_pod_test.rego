package test.terraform.analysis

import data.terraform.analysis

test_allow_if_valid_service_pod_and_irsa if {
	result := analysis.allow with input as sp_mock_tfplan
	result == true
}

test_deny_if_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
	result == false
}

test_deny_if_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
	result == false
}

test_deny_if_namespace_mismatch if {
	modified_plan := {
		"address": sp_mock_tfplan.resource_changes[2].address,
		"type": sp_mock_tfplan.resource_changes[2].type,
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
		"variables": sp_mock_tfplan.variables,
		"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes[0]],
	}
	result == false
}

test_deny_if_service_pod_irsa_mismatch if {
	modified_irsa := {
		"address": sp_mock_tfplan.resource_changes[0].address,
		"type": sp_mock_tfplan.resource_changes[0].type,
		"change": {
			"actions": ["no-op"],
			"after": {"metadata": [{"name": "non-existent-sa", "namespace": "testing-ns"}]},
		},
	}

	result := analysis.allow with input as {
		"variables": sp_mock_tfplan.variables,
		"resource_changes": [sp_mock_tfplan.resource_changes[2], modified_irsa],
	}
	result == false
}

test_deny_if_involve_other_resource_change if {
	modified_plan := {
		"address": "aws_s3_bucket",
		"type": "aws_s3_bucket",
		"change": {"actions": ["update"]},
	}

	result := analysis.allow with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes[_]]}
	result == false
}

test_deny_if_irsa_change if {
	modified_irsa := {
		"address": sp_mock_tfplan.resource_changes[0].address,
		"type": "kubernetes_service_account",
		"change": {
			"actions": ["update"],
			"after": {"metadata": [{"name": "testing-sa-1", "namespace": "testing-ns"}]},
		},
	}

	result := analysis.allow with input as {
		"variables": sp_mock_tfplan.variables,
		"resource_changes": [sp_mock_tfplan.resource_changes[2], modified_irsa],
	}
	result == false
}
