package test.terraform.analysis

import data.terraform.analysis

test_allow_default if {
	result := analysis.allow with input as ecr_create_mock_tfplan
	result == true
}

test_allow_if_op_update if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_deny_if_op_update_changes_name if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test-changed"},
		},
	}

	not analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_allow_if_op_destroy if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["delete"],
			"before": {"name": "this", "force_delete": true},
			"after": {"name": "this", "force_delete": true},
		},
	}

	analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_allow_if_op_destroy_with_no_protect if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["delete"],
			"after": {"force_delete": true},
		},
	}

	not analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_deny_if_op_destroy if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["delete"],
			"after": {"force_delete": false},
		},
	}

	not analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_deny_if_op_module_rename if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["create", "delete"],
			"before": {"name": "jazz-test"},
			"after": {
				"name": "jazz-test-changed",
				"force_delete": true,
			},
		},
	}

	not analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
}

test_allow_if_does_not_contain_ecr if {
	analysis.allow with input as {"resource_changes": []}
}
