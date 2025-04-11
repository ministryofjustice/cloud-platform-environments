package terraform.analysis

import input as tfplan
import future.keywords.every

default allow := false

allow if {
	not touches_other_resources
}

ecr_module_addrs = [m | m := tfplan.resource_changes[_]; m.type == `aws_ecr_repository`]
service_pod_addrs = [sp | sp := tfplan.resource_changes[_]; regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)]

allowed_modules := array.concat(service_pods_addrs, ecr_module_addrs)

allowed_modules_addrs := {arr | arr := allowed_modules[_].module_address}

touches_other_resources if {
	all_modules_addrs := [
	res |
		res := tfplan.resource_changes[_]
		res.change.actions[_] != "no-op"
		regex.match(`module\.`, res.module_address)
		res = res.module_address
	]

	every m in all_modules_addrs {
		m in allowed_modules_addrs
	}
}
