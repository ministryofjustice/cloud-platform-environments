package terraform.analysis

import input as tfplan
import future.keywords.every

default allow := false

default res := false

allow := {
	"valid": res,
	"msg": msg
}

res if {
	doesnt_touch_other_resources
	not touches_iam_create
	not touches_iam_update
}

msg = "Valid changes the PR meets the module allowlist criteria for auto approval" if {
	doesnt_touch_other_resources
	not touches_iam_create
	not touches_iam_update
} else := "This PR includes create changes to IAM that are not covered by our module allowlist, so we can't auto approve this PR. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	touches_iam_create
} else := "This PR includes update changes to IAM that are not covered by our module allowlist, so we can't auto approve this PR. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)" if {
	touches_iam_update
} else := "This PR includes changes to modules / resources which are not on the allowlist, so we can't auto approve these changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"

ecr_module_addrs := [m | m := tfplan.resource_changes[_]; m.type == `aws_ecr_repository`]

service_pod_addrs := [sp |
sp := tfplan.resource_changes[_]
regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, sp.address)
]

allowed_modules := array.concat(service_pod_addrs, ecr_module_addrs)

allowed_modules_addrs := {arr | arr := allowed_modules[_].module_address}

doesnt_touch_other_resources if {

	count(allowed_modules_addrs) > 0

	all_modules := [
	res |
		res := tfplan.resource_changes[_]
		res.change.actions[_] != "no-op"
		regex.match(`module\.`, res.module_address)
		]

	all_modules_addrs := [
		res |
		res := all_modules[_].module_address
	]


	every m in all_modules_addrs {
		m in allowed_modules_addrs
	}
}

touches_iam_create if {
	all_iam := [
	p |
		p := tfplan.resource_changes[_]
		p.type in {"aws_iam_policy", "aws_iam_role_policy_attachment"}
		change := p.change.actions[_]
		change == "create"
	]
	
	count(all_iam) > 0

	all_iam_addrs := [
		res |
		res := all_iam[_].module_address
	]

	every m in all_iam_addrs {
		not m in allowed_modules_addrs
	}

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

	all_iam_addrs := [
		res |
		res := all_iam[_].module_address
	]

	every m in all_iam_addrs {
		not m in allowed_modules_addrs
	}
}
