package test.terraform.analysis

import data.terraform.analysis

test_allow_if_iam_changes_and_allowlist_module_is_changed if {
	res := analysis.allow with input as sp_mock_tfplan
	res.valid
	res.msg == "Valid changes the PR meets the module allowlist criteria for auto approval"
}

test_deny_if_update_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["update"]},
	}

	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}

test_deny_if_update_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["update"]},
	}

	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}

test_deny_if_create_iam_policy_changes if {
	modified_plan := {
		"address": "aws_iam_policy",
		"type": "aws_iam_policy",
		"change": {"actions": ["create"]},
	}

	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}

test_deny_if_update_iam_policy_attachment_changes if {
	modified_plan := {
		"address": "aws_iam_role_policy_attachment",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["create"]},
	}

	res := analysis.allow with input as {"resource_changes": [mock_tfplan.resource_changes, mock_tfplan.resource_changes]}
	not res.valid
	res.msg == "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"
}
