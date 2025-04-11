package terraform.analysis

import input as tfplan

import future.keywords.every

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

ecr_update_ok if {
	updates := [
	res |
		res := ecr_module_resources[_]
		res.change.actions[_] == "update"
	]

	every ecr in updates {
		is_ecr_update_valid(ecr)
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

is_ecr_resource(res) if res.module_address in ecr_module_addrs
