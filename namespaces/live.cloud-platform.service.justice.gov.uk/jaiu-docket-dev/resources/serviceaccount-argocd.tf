/*
 * Deployer identity for the JusticeAI Unit's ArgoCD
 *
 * ArgoCD registers this cluster as an external, namespace-scoped cluster: a
 * cluster Secret on the ArgoCD side carries this service account's token, the
 * API server URL and CA, `namespaces: jaiu-docket-dev` and
 * `clusterResources: "false"`, so it never asks for anything outside the
 * namespace. `argocd cluster add` is not used because it creates a ClusterRole.
 *
 * The role below lists what the chart renders (Deployments, Services,
 * ConfigMaps, Secrets, ServiceAccounts, Ingresses, Jobs, hook Pods) plus the
 * kinds ArgoCD watches to report health (ReplicaSets, Pods, Events, Endpoints)
 * and the kinds the chart can enable later (HPAs, PDBs, NetworkPolicies,
 * CronJobs, StatefulSets, ServiceMonitors). It is a Role, not a ClusterRole,
 * so it is bounded by this namespace whatever the verbs say.
 *
 * Reading the credential after apply (the module stores a long-lived token):
 *
 *   kubectl -n jaiu-docket-dev get secret <default_secret_name> \
 *     -o go-template='{{index .data "token" | base64decode}}'
 *   kubectl -n jaiu-docket-dev get secret <default_secret_name> \
 *     -o go-template='{{index .data "ca.crt"}}'          # already base64, as caData wants it
 *
 * The secret name is the module output `default_secret_name`
 * (`argocd-token-<suffix>`); the API server URL is the `server` field in your
 * kubeconfig for live. Rotate by changing serviceaccount_token_rotated_date,
 * re-applying, and updating the ArgoCD cluster Secret.
 *
 * Separate from module.serviceaccount (`cd-serviceaccount`), which keeps the
 * narrower GitHub Actions deploy rights, so either can be rotated or removed
 * without touching the other.
 */
module "argocd_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "argocd"
  role_name           = "argocd-role"
  rolebinding_name    = "argocd-rolebinding"

  # dd-mm-yyyy. Change to mint a new token; see the header for what to update on the ArgoCD side.
  serviceaccount_token_rotated_date = "05-10-2026"

  # Every rule is a subset of the `admin` ClusterRole the team holds in this
  # namespace (RoleBinding jaiu-docket-dev-admin), so the deployer can never do
  # more than the people who own it.
  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "configmaps",
        "persistentvolumeclaims",
        "pods",
        "secrets",
        "serviceaccounts",
        "services",
      ]
      verbs = [
        "get",
        "list",
        "watch",
        "create",
        "update",
        "patch",
        "delete",
      ]
    },
    {
      # Read-only: ArgoCD watches these for health and shows logs, nothing more.
      api_groups = [""]
      resources  = ["endpoints", "events", "pods/log"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = [
        "apps",
        "batch",
        "networking.k8s.io",
        "policy",
        "autoscaling",
      ]
      resources = [
        "deployments",
        "replicasets",
        "statefulsets",
        "jobs",
        "cronjobs",
        "ingresses",
        "networkpolicies",
        "poddisruptionbudgets",
        "horizontalpodautoscalers",
      ]
      verbs = [
        "get",
        "list",
        "watch",
        "create",
        "update",
        "patch",
        "delete",
      ]
    },
    {
      # Only if the chart ever turns RBAC on for a subchart (Dex ships with it off here).
      api_groups = ["rbac.authorization.k8s.io"]
      resources  = ["roles", "rolebindings"]
      verbs = [
        "get",
        "list",
        "watch",
        "create",
        "update",
        "patch",
        "delete",
      ]
    },
    {
      api_groups = ["monitoring.coreos.com"]
      resources  = ["servicemonitors", "prometheusrules"]
      verbs = [
        "get",
        "list",
        "watch",
        "create",
        "update",
        "patch",
        "delete",
      ]
    },
  ]
}
