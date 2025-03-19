package test.terraform.analysis

import data.terraform.analysis

test_allow_default if {
	result := analysis.allow.valid with input as ecr_create_mock_tfplan
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

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.msg == "Valid ECR related terraform changes. These changes meet the criteria for auto approval"
	res.valid == true
}

test_allow_if_op_update_changes_name if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test-changed"},
		},
	}

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.msg == "NOTE: you are changing a variable which is used to construct your ECR repo name but the repo name cannot be changed because it will force destroy and recreate the entire ECR repo"
	res.valid == true
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

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.msg == "Valid ECR related terraform changes. These changes meet the criteria for auto approval"
	res.valid == true
}

test_allow_if_op_destroy_with_no_protect if {
	modified_plan := {
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["delete"],
			"before": {"name": "this", "force_delete": true},
			"after": {"name": "this", "force_delete": true},
		},
	}

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.valid == true
	res.msg == "Valid ECR related terraform changes. These changes meet the criteria for auto approval"
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

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.valid == false
  res.msg == "Invalid ECR destroy terraform changes. Please request a Cloud Platform team members review in #ask-cloud-platform"
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

	res := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	res.valid == true
	res.msg == "NOTE: you are changing a variable which is used to construct your ECR repo name but the repo name cannot be changed because it will force destroy and recreate the entire ECR repo"

}

test_allow_if_does_not_contain_ecr if {
	analysis.allow.valid with input as {"resource_changes": []}
}
