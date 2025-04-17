package terraform.analysis

import input as tfplan

is_ecr_update_valid(ecr) if {
	before := ecr.change.before.name
	after := ecr.change.after.name
	before == after
}
