module "serviceaccount_live" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.5"

  namespace                            = var.namespace
  github_repositories                  = ["helloworld-poornima-dev"]
  github_actions_secret_kube_namespace = "KUBE_LIVE_NAMESPACE"
  github_actions_secret_kube_cert      = "KUBE_LIVE_CERT"
  github_actions_secret_kube_token     = "KUBE_LIVE_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_LIVE_CLUSTER"
  serviceaccount_name = "cd-live-serviceaccount"
}