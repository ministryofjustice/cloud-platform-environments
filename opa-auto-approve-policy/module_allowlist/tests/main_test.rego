package test.terraform.analysis

import data.terraform.analysis

test_deny_no_module if {
	not analysis.allow.valid with input as {"resource_changes": [mock_tfplan.resource_changes]}
}

test_deny_untested_module if {
	modified_plan := {
		"module_address": "module.module",
		"type": "aws_foobar_repository",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	not analysis.allow.valid with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
}

test_allow_if_other_module_noop if {
	modified_plan := {
		"module_address": "module.module",
		"type": "aws_foobar_repository",
		"change": {
			"actions": ["no-op"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	not analysis.allow.valid with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
}

test_allow_ecr if {
	modified_plan := {
		"address": "module.ecr.foobar",
		"module_address": "module.ecr",
		"type": "aws_ecr_repository",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	analysis.allow.valid with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
}

test_allow_service_pod if {
	modified_plan := {
		"address": "module.sp.kubernetes_deployment.service_pod",
		"module_address": "module.sp",
		"change": {
			"actions": ["update"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	analysis.allow.valid with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
}
