package terraform.analysis

import input as tfplan

import future.keywords.every

default allow := false

default ecr_create_ok := false

default ecr_update_ok := false

default ecr_destroy_ok := false

default res := false

allow := {
	"valid": res,
	"msg": msg
}

res if {
	ecr_create_ok
	ecr_destroy_ok
}

msg = "NOTE: you are changing a variable which is used to construct your ECR repo name but the repo name cannot be changed because it will force destroy and recreate the entire ECR repo" if {
	ecr_repo_rename_ok
} else := "Valid ECR related terraform changes" if {
	ecr_create_ok
	ecr_destroy_ok
} else := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_create_ok
	not ecr_destroy_ok
} else := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_create_ok
} else := "We can't auto approve these ECR terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	not ecr_destroy_ok
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
	all_ecr := [
		res |
			res := ecr_module_resources[_]
	]

	count(all_ecr) > 0

	every ecr in all_ecr {
		before := ecr.change.before.name
		after := ecr.change.after.name
		before != after
	}
}

is_ecr_resource(res) if res.module_address in ecr_module_addrs
