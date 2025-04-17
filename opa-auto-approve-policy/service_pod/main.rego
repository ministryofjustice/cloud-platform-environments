package terraform.analysis

import input as tfplan

default service_pod_ok := false

default touches_iam := true

allow := {
	"valid": res,
	"msg": msg,
}

res if {
	service_pod_ok
}

msg := "Valid Service pod related changes" if {
	service_pod_ok
} else := "We can't auto approve these Service Pod terraform changes. Please request a Cloud Platform team members review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"

service_pod_ok if {
	service_pods := [
	res |
		res := tfplan.resource_changes[_]
		regex.match(`^module\..*\.kubernetes_deployment\.service_pod$`, res.address)
		res.change.actions[_] != "no-op"
	]

	every sp in service_pods {
		is_service_pod_valid(sp)
	}
}
