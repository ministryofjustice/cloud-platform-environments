package terraform.analysis

import input as tfplan

is_ecr_destroy_valid(ecr)

if {
	before := ecr.change.before.name
	after := ecr.change.after.name

	after_delete_protection := ecr.change.after.force_delete
	after_delete_protection == true
	before == after
}
