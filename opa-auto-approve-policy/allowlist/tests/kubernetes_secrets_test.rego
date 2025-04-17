package test.terraform.analysis

import data.terraform.analysis

test_allow_kubernetes_secret if {
	modified_plan := {
		"address": "kubernetes_secret.test",
		"type": "kubernetes_secret",
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
