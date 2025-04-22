package test.terraform.analysis

import data.terraform.analysis

test_deny_noop_service_pod if {
	modified_plan := {
		"address": "module.sp.kubernetes_deployment.service_pod",
		"module_address": "module.sp",
		"change": {
			"actions": ["no-op"],
			"before": {"name": "jazz-test"},
			"after": {"name": "jazz-test"},
		},
	}

	res := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
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

	res := analysis.allow with input as {"resource_changes": [modified_plan, mock_tfplan.resource_changes]}
	res.valid
	res.msg == "Valid changes the PR meets the module allowlist criteria for auto approval"
}
