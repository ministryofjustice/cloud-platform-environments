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
}

msg = "Valid changes, this PR meets the module allowlist criteria for auto approval" if {
	doesnt_touch_other_resources
} else := "Invalid changes, this PR includes changes to modules / resources which are not on the allowlist for the OPA auto approver. Please request a Cloud Platform team member's review in #ask-cloud-platform"

ecr_module_addrs := [m | m := tfplan.resource_changes[_]; m.type == `aws_ecr_repository`]

service_pod_addrs := [sp |
sp := tfplan.resource_changes[_]
regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, sp.address)
]

doesnt_touch_other_resources if {
	allowed_modules := array.concat(service_pod_addrs, ecr_module_addrs)

	allowed_modules_addrs := {arr | arr := allowed_modules[_].module_address}

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
