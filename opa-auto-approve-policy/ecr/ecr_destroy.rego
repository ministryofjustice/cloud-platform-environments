package terraform.analysis

import input as tfplan

is_ecr_destroy_valid(ecr) if {
	after_delete_protection := ecr.change.after.force_delete
	after_delete_protection == true
}
