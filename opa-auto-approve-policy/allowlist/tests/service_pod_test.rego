package test.terraform.analysis

import data.terraform.analysis

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

	res := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
	res.valid
	res.msg == "Valid changes the PR meets the module allowlist criteria for auto approval"
}
