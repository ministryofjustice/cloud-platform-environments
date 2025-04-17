package test.terraform.analysis

import data.terraform.analysis

test_deny_no_module if {
	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
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

	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}

test_deny_if_other_module_noop if {
	modified_plan := {
		"module_address": "module.module",
		"type": "aws_foobar_repository",
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
