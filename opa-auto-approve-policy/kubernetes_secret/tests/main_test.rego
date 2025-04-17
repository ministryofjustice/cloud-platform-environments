package test.terraform.analysis

import data.terraform.analysis

test_allow_if_secret_create if {
	res := analysis.allow with input as mock_tfplan
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_allow_if_secret_update if {
	res := analysis.allow with input as {"variables": mock_tfplan.variables, "resource_changes": mock_tfplan.resource_changes}
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_allow_if_secret_destroy if {
	res := analysis.allow with input as {"variables": mock_tfplan.variables, "resource_changes": mock_tfplan.resource_changes}
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_deny_if_secret_cross_namespace if {
	modified_plan := {"namespace": {"value": "wrong"}}

	res := analysis.allow with input as {"variables": modified_plan, "resource_changes": mock_tfplan.resource_changes}
	print(res)
	res.msg == "We can't auto approve these kubernetes secret terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
	not res.valid
}

test_allow_if_secret_v1_create if {
	res := analysis.allow with input as mock_tfplan_v1
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_allow_if_secret_v1_update if {
	res := analysis.allow with input as {"variables": mock_tfplan.variables, "resource_changes": mock_tfplan_v1.resource_changes}
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_allow_if_secret_v1_destroy if {
	res := analysis.allow with input as {"variables": mock_tfplan.variables, "resource_changes": mock_tfplan_v1.resource_changes}
	res.valid
	res.msg == "Valid ECR related terraform changes"
}

test_deny_if_secret_v1_cross_namespace if {
	modified_plan := {"namespace": {"value": "wrong"}}

	res := analysis.allow with input as {"variables": modified_plan, "resource_changes": mock_tfplan_v1.resource_changes}
	res.msg == "We can't auto approve these kubernetes secret terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
	not res.valid
}

test_deny_if_secret_v1_create_is_invalid_but_secret_is_valid if {
	res := analysis.allow with input as mock_tfplan_invalid
	not res.valid
	res.msg == "We can't auto approve these kubernetes secret terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}
