package test.terraform.analysis

import data.terraform.analysis

test_allow_default if {
    result := analysis.allow with input as ecr_create_mock_tfplan
    result == true
}

test_deny_if_op_not_create if {
    modified_plan := {
        "address": "module.ecr_2.aws_ecr_repository.repo",
        "type": "aws_ecr_repository",
        "change": {"actions": ["update"]},
    }

    result := analysis.allow with input as {"resource_changes": [modified_plan, ecr_create_mock_tfplan.resource_changes]}
	result == false
}