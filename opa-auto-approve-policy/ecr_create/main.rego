package terraform.analysis

import input as tfplan

default allow := false

default ecr_create_ok := false

allow if ecr_create_ok

ecr_create_ok if {
	ecrs := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`module\.ecr`, res.module_address)
		regex.match(`aws_ecr_repository`, res.type)
		res.change.actions[_] == "create"
	]

	count(ecrs) > 0
	every ecr in ecrs {
		is_ecr_create_valid(ecr)
	}
}