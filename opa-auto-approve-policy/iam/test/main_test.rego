package test.terraform.analysis

import data.terraform.analysis

test_allow_if_valid_no_iam_changes if {
	analysis.allow.valid with input as sp_mock_tfplan
}

test_deny_if_update_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["update"]},
	}

	not analysis.allow.valid with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
}

test_deny_if_update_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["update"]},
	}

	not analysis.allow.valid with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
}

test_deny_if_create_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["create"]},
	}

	not analysis.allow.valid with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
}

test_deny_if_update_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["create"]},
	}

	not analysis.allow.valid with input as {"resource_changes": [modified_plan, sp_mock_tfplan.resource_changes]}
}
