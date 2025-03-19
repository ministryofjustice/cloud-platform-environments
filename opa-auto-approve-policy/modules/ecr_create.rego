package terraform.analysis

import input as tfplan

is_ecr_create_valid(ecr) if {
    repo_names := [
	name |
		name := ecr.change.after.name
	]

    is_correct_repo_name := tfplan.variables.namespace.value
	every name in repo_names {
		name == is_correct_repo_name
	}
}