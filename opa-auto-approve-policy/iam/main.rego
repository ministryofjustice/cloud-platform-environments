package terraform.analysis

import input as tfplan

default allow := false

default res := false

default touches_iam := true

allow := {
	"valid": res,
	"msg": msg
}

res if {
	not touches_iam_create
	not touches_iam_update
}

msg = "Valid changes as the PR contains no IAM sensitive changes. These changes meet the criteria for auto approval" if {
	not touches_iam_create
	not touches_iam_update
} else := "Invalid changes as the PR contains IAM related terraform. Please request a Cloud Platform team members review in #ask-cloud-platform"

touches_iam_create if {
	all_iam := [
	p |
		p := tfplan.resource_changes[_]
		p.type in {"aws_iam_policy", "aws_iam_role_policy_attachment"}
		change := p.change.actions[_]
		change == "create"
	]
	count(all_iam) > 0
}

touches_iam_update if {
	all_iam := [
	p |
		p := tfplan.resource_changes[_]
		p.type in {"aws_iam_policy", "aws_iam_role_policy_attachment"}
		change := p.change.actions[_]
		change == "update"
	]
	count(all_iam) > 0
}
