package terraform.analysis

import input as tfplan

import future.keywords.every

default allow := false

default ecr_create_ok := false

default ecr_destroy_ok := false

default res := false

allow := {
	"valid": res,
	"msg": msg,
}

res if {
	ecr_create_ok
	ecr_destroy_ok
}

msg := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_create_ok
	not ecr_destroy_ok
} else := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_create_ok
} else := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_destroy_ok
} else := "NOTE: Terraform `team_name` / `repo_name` change detected. ECR repository names cannot be updated in place to reflect these changes.[see here](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/aws-resource-naming-issue.html)" if {
	not ecr_repo_rename_ok
} else := "Valid ECR related terraform changes" if {
	ecr_create_ok
	ecr_destroy_ok
}

ecrs := [
res |
	res := tfplan.resource_changes[_]
	regex.match(`aws_ecr_repository`, res.type)
]

ecr_module_addrs := {arr | arr := ecrs[_].module_address}

ecr_module_resources := [
res |
	res := tfplan.resource_changes[_]

	is_ecr_resource(res)
]

repo_name := tfplan.variables.namespace.value if {
	tfplan.configuration.root_module.module_calls.ecr_expressions.repo_name.references[0] == "var.namespace"
} else := tfplan.configuration.root_module.module_calls.ecr_expressions.repo_name.constant_value[0]

ecr_create_ok if {
	creates := [
	res |
		res := ecr_module_resources[_]
		res.change.actions[_] == "create"
	]

	every ecr in creates {
		is_ecr_create_valid(ecr)
	}
}

ecr_destroy_ok if {
	destroys := [
	res |
		res := ecr_module_resources[_]
		res.change.actions[_] == "delete"
	]

	every ecr in destroys {
		is_ecr_destroy_valid(ecr)
	}
}

ecr_repo_rename_ok if {
	every ecr in ecrs {
		after := ecr.change.after.name
		full_repo_name := sprintf("%s/%s", [tfplan.variables.team_name.value, repo_name])
		after == full_repo_name
	}
}

is_ecr_resource(res) if res.module_address in ecr_module_addrs
