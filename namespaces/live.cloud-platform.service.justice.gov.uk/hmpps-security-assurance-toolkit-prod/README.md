# HMPPS Security Assurance Toolkit - Production

This directory defines the production Kubernetes namespace and supporting AWS resources for the HMPPS Security Assurance Toolkit.

## Namespace

- **Cluster:** `live.cloud-platform.service.justice.gov.uk`
- **Namespace:** `hmpps-security-assurance-toolkit-prod`
- **Environment:** Production
- **Business unit:** HMPPS
- **Service area:** DevSecOps
- **Team:** `hmpps-sre`
- **Support:** dps-hmpps@digital.justice.gov.uk
- **Slack:** `hmpps-sre-alerts-prod`
- **Public hostname:** https://security-assurance-toolkit.hmpps.service.justice.gov.uk

The namespace has the restricted pod security standard enforced.

## Applications

The namespace supports two Ministry of Justice GitHub repositories:

- [HMPPS Security Assurance Toolkit](https://github.com/ministryofjustice/hmpps-security-assurance-toolkit)
- [HMPPS Security Assurance Discovery Agent](https://github.com/ministryofjustice/hmpps-security-assurance-discovery-agent)

Terraform creates the CI/CD and Kubernetes service-account resources for each application using the Cloud Platform HMPPS template module.

## Infrastructure

### Kubernetes resources

| File | Purpose |
| --- | --- |
| `00-namespace.yaml` | Creates the production namespace and team metadata |
| `01-rbac.yaml` | Grants the `github:hmpps-sre` GitHub team admin access |
| `02-limitrange.yaml` | Sets container default requests and limits |
| `03-resourcequota.yaml` | Limits the namespace to 50 pods |
| `04-networkpolicy.yaml` | Allows pod-to-pod and ingress-controller traffic |
| `05-certificates.yaml` | Requests a Let's Encrypt certificate for the public hostname |

The default container limits are `1000m` CPU and `2000Mi` memory. The default container requests are `10m` CPU and `100Mi` memory.

Ingress is restricted to traffic from pods in the namespace or the Cloud Platform ingress-controller namespace.

### AWS and Terraform resources

The files in `resources/` provision supporting infrastructure:

- PostgreSQL 17 RDS instance for the toolkit
- Toolkit database connection and discovery outputs
- GitHub Actions and Kubernetes service-account integration
- AWS, GitHub, and Kubernetes providers

The RDS instance uses a `db.t4g.medium` instance class in eu-west-2 and allows storage to scale up to 500 GB. The allocated storage is 20 GB with General Purpose SSD storage.

Terraform state is stored in the remote S3 backend. The repository's normal CI/CD pipeline is responsible for planning and applying changes.

## Making changes

1. Create a branch and update the YAML or Terraform files in this directory.
2. Run formatting and validation checks locally where available.
3. Open a pull request for review by `hmpps-sre`.
4. Merge only after the Cloud Platform pipeline checks pass.

For example:

```bash
cd resources
terraform fmt -check
terraform validate
```

Terraform provider credentials and the remote backend are supplied by the Cloud Platform environment; no credentials should be committed to this repository.

## Access

Members of the `github:hmpps-sre` GitHub team have administrator access to this namespace.

Use the Cloud Platform tooling or `kubectl` with the namespace explicitly selected:

```bash
kubectl get pods -n hmpps-security-assurance-toolkit-prod
kubectl get services -n hmpps-security-assurance-toolkit-prod
kubectl get certificates -n hmpps-security-assurance-toolkit-prod
```

Do not copy or commit Kubernetes secrets or database credentials.

## Database operations

The PostgreSQL database is managed by the Terraform RDS module in `resources/rds.tf`. Its generated connection details are supplied to the toolkit through Kubernetes configuration and secrets.

Before changing the database engine, instance class, or storage settings:

- Review Cloud Platform RDS and PostgreSQL upgrade guidance.
- Confirm whether the change requires downtime or a maintenance window.
- Plan and apply through the normal pull-request and CI/CD process.
- Verify the application after the change.

The database password rotation date is maintained in `resources/rds.tf`. New secret values must be consumed through the application deployment process rather than edited directly in Kubernetes.
