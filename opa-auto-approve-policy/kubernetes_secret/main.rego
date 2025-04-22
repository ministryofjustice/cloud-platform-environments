package terraform.analysis

import input as tfplan

import future.keywords.every

default k8s_secret_ok := false

default k8s_secret_v1_ok := false

default res := false

ns := tfplan.variables.namespace.value

allow := {
	"valid": res,
	"msg": msg,
}

res if {
	k8s_secret_ok
	k8s_secret_v1_ok
}

msg := "Valid K8s secret related terraform changes" if {
	k8s_secret_ok
	k8s_secret_v1_ok
} else := "We can't auto approve these kubernetes secret terraform changes. Please request a Cloud Platform team member's review in [#ask-cloud-platform](https://moj.enterprise.slack.com/archives/C57UPMZLY)"

k8s_secret_ok if {
	k8s_secrets := [
	res |
		res := tfplan.resource_changes[_]
		res.type == "kubernetes_secret"
		res.change.actions[_] != "no-op"
	]

	every s in k8s_secrets {
		s.change.after.metadata[0].namespace == ns
	}
}

k8s_secret_v1_ok if {
	k8s_secrets_v1 := [
	res |
		res := tfplan.resource_changes[_]
		res.type == "kubernetes_secret_v1"
		res.change.actions[_] != "no-op"
	]

	every s in k8s_secrets_v1 {
		s.change.after.metadata[0].namespace == ns
	}
}
