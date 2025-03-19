package terraform.analysis

import input as tfplan

default allow := false

default ecr_create_ok := false

default ecr_update_ok := false

default ecr_destroy_ok := false

allow if {
	ecr_create_ok
	ecr_update_ok
	ecr_destroy_ok
}

ecrs := [
res |
	res := tfplan.resource_changes[_]
	regex.match(`module\.ecr`, res.module_address)
	regex.match(`aws_ecr_repository`, res.type)
]

ecr_create_ok if {
	creates := [
	res |
		res := ecrs[_]
		res.change.actions[_] == "create"
	]

	every ecr in creates {
		is_ecr_create_valid(ecr)
	}
}

ecr_update_ok if {
	updates := [
	res |
		res := ecrs[_]
		res.change.actions[_] == "update"
	]

	every ecr in updates {
		is_ecr_update_valid(ecr)
	}
}

ecr_destroy_ok if {
	destroys := [
	res |
		res := ecrs[_]
		res.change.actions[_] == "delete"
	]

	every ecr in destroys {
		is_ecr_destroy_valid(ecr)
	}
}
