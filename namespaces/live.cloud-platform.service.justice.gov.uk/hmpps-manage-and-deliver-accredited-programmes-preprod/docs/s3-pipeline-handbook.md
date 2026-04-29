# S3 Data Pipeline — Golden Handbook
**Namespace:** `hmpps-manage-and-deliver-accredited-programmes-preprod`  
**Last Updated:** 2026-04-29

---

## Overview

This document describes the full S3 data pipeline used to receive `.bak` SQL Server backup files from NEC (an external supplier), transfer them into an internal bucket, and restore them into the preprod RDS SQL Server instance nightly.

---

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  NEC AWS Account (778742069978)                                             │
│                                                                             │
│  IAM Role: im-preprod-s3-datasync   ◄── ⚠️ CURRENTLY COMMENTED OUT        │
│  IAM Role: im-production-s3-datasync  ◄── active (but likely wrong role)   │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │  s3:PutObject / s3:GetObject etc.
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  BUCKET 1: upload_s3_bucket                                                 │
│  cloud-platform-421f9ae70e6559d242c61fe413ef46a4                            │
│  (NEC landing zone — files arrive here)                                     │
│  Region: eu-west-2 (London)                                                 │
│  Logging: → s3_upload_logging_bucket (logs/ prefix)                        │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │
                     05:00 UTC daily
                  CronJob: hmpps-manage-and-deliver-acp-s3-transfer
                  aws s3 sync  (copies all files across)
                  aws s3 rm --recursive  (⚠️ DELETES source after sync)
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  BUCKET 2: sqlserver_backup_s3_bucket                                       │
│  (Internal destination — .bak files live here)                              │
│  Region: eu-west-2 (London)                                                 │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │
                     05:45 UTC daily
                  CronJob: db-restore-cronjob
                  Finds latest .bak → RDS native restore via rds_restore_database
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  RDS SQL Server (sqlserver-web 15.0)                                        │
│  Instance: hmpps-manage-and-deliver-acp-preprod-mssql                       │
│  db.m5.large  |  600GB gp2 storage                                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  BUCKET 3: s3_upload_logging_bucket                                         │
│  (S3 access logs for upload_s3_bucket — read-only audit trail)              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Bucket Reference

### Bucket 1 — `upload_s3_bucket` (NEC Landing Zone)

| Property | Value |
|----------|-------|
| Terraform module | `module.upload_s3_bucket` |
| Kubernetes secret | `upload-s3-bucket-output` |
| Secret keys | `bucket_name`, `bucket_arn` |
| Region | `eu-west-2` (London) |
| Logging enabled | `true` |
| Log prefix | `logs/` |
| Log target | `s3_upload_logging_bucket` |
| Terraform source | `cloud-platform-terraform-s3-bucket?ref=5.3.0` |

**Bucket Policy — who can access:**
| Principal | Type | Actions | Status |
|-----------|------|---------|--------|
| `module.irsa-cronjob.role_arn` | Internal K8s service account | Full (PutObject, GetObject, ListBucket, DeleteObject, etc.) | ✅ Active |
| `arn:aws:iam::778742069978:role/im-preprod-s3-datasync` | NEC preprod role | Full | ⚠️ **COMMENTED OUT — role does not exist in NEC's AWS account** |
| `arn:aws:iam::778742069978:role/im-production-s3-datasync` | NEC production role | Full | ✅ Active |

**Bucket Policy Actions (both NEC and internal):**
```
s3:PutObject, s3:GetObject, s3:ListBucket, s3:DeleteObject,
s3:GetBucketLocation, s3:GetObjectAcl, s3:GetObjectVersion,
s3:GetObjectTagging, s3:ListBucketMultipartUploads,
s3:ListMultipartUploadParts, s3:AbortMultipartUpload
```

---

### Bucket 2 — `sqlserver_backup_s3_bucket` (Internal .bak Store)

| Property | Value |
|----------|-------|
| Terraform module | `module.sqlserver_backup_s3_bucket` |
| Kubernetes secret | `sqlserver-backup-s3-bucket-output` |
| Secret keys | `bucket_name`, `bucket_arn` |
| Region | `eu-west-2` (London) |
| Logging enabled | No explicit logging config |
| Terraform source | `cloud-platform-terraform-s3-bucket?ref=5.3.0` |

**Who can access:**
| Principal | Via | Actions |
|-----------|-----|---------|
| `irsa-s3-cronjob` service account | `module.irsa-cronjob` IRSA policy | Write (sync destination) |
| `irsa-sqlserver` service account | `module.irsa-sqlserver` IRSA policy | Read (ListBucket to find latest .bak) |

---

### Bucket 3 — `s3_upload_logging_bucket` (Audit Logs)

| Property | Value |
|----------|-------|
| Terraform module | `module.s3_upload_logging_bucket` |
| Kubernetes secret | `s3-logging-bucket-output` |
| Secret keys | `BUCKET_ARN`, `BUCKET_NAME` |
| Purpose | Receives S3 access logs from `upload_s3_bucket` |

**Bucket Policy:**
- `logging.s3.amazonaws.com` → `s3:PutObject` (AWS writes logs here)
- `irsa-s3-cronjob` → `s3:GetObject`, `s3:ListBucket` (read logs)

---

## IRSA (IAM Roles for Service Accounts)

| Module | Service Account | Bucket Access | Other Access |
|--------|----------------|---------------|-------------|
| `module.irsa-cronjob` | `irsa-s3-cronjob` | `upload_s3_bucket` + `sqlserver_backup_s3_bucket` | — |
| `module.irsa-sqlserver` | `irsa-sqlserver` | `sqlserver_backup_s3_bucket` (read/list) | RDS SQL Server |
| `module.irsa` | `hmpps-manage-and-deliver-accredited-programmes` | — | SQS, SNS, ElastiCache |

All IRSA modules use: `cloud-platform-terraform-irsa?ref=2.1.0`

---

## CronJob 1 — S3 Transfer (`cronjob-s3-transfer.yaml`)

| Property | Value |
|----------|-------|
| Name | `hmpps-manage-and-deliver-acp-s3-transfer` |
| Schedule | `0 5 * * *` — **05:00 UTC / 06:00 BST daily** |
| Service account | `irsa-s3-cronjob` |
| Image | `public.ecr.aws/aws-cli/aws-cli:2.15.15` |
| Concurrency | `Forbid` (only one run at a time) |
| Retry on failure | `backoffLimit: 3` with `restartPolicy: OnFailure` |
| Successful jobs kept | 3 |
| Failed jobs kept | 5 |

**Environment Variables:**

| Variable | Source | Description |
|----------|--------|-------------|
| `HOME` | hardcoded `/tmp` | Required for AWS CLI in non-root container |
| `UPLOAD_S3_BUCKET_NAME` | Secret `upload-s3-bucket-output` → `bucket_name` | NEC landing bucket name |
| `SQLSERVER_BACKUP_S3_BUCKET_NAME` | Secret `sqlserver-backup-s3-bucket-output` → `bucket_name` | Internal .bak bucket name |

**What it does (in order):**
1. `aws s3 sync s3://$UPLOAD_S3_BUCKET_NAME s3://$SQLSERVER_BACKUP_S3_BUCKET_NAME` — copies all files
2. `aws s3 rm s3://$UPLOAD_S3_BUCKET_NAME --recursive` — **⚠️ deletes everything from the upload bucket**

> **Important:** After the job runs, `upload_s3_bucket` will always be empty. This is by design — files live in `sqlserver_backup_s3_bucket` after the nightly run.

---

## CronJob 2 — DB Restore (`db_restore.yaml`)

| Property | Value |
|----------|-------|
| Name | `db-restore-cronjob` |
| Schedule | `45 5 * * *` — **05:45 UTC / 06:45 BST daily** (45 min after S3 transfer) |
| Service account | `irsa-sqlserver` |
| Concurrency | `Forbid` |
| Retry on failure | `backoffLimit: 3` |

**Init Containers (run in order):**

1. **`create-rds-snapshot`** — Takes an RDS snapshot before restore (if `CREATE_SNAPSHOT=true`)
2. **`find-backup-file`** — Lists `sqlserver_backup_s3_bucket`, sorts by name, picks the **latest file** (by sort order), writes key to shared volume `/backup-info/backup-key`
3. **`port-forward`** — Sidecar that port-forwards to RDS on port 1433 (stays up for the main container)

**Main Container: `db-restore`**

| Variable | Source | Description |
|----------|--------|-------------|
| `DB_PORT` | ConfigMap `rds-sqlserver-restore-config-map` → `db_port` | SQL Server port (1433) |
| `DATABASE_NAME` | Secret `rds-sqlserver-instance-output` → `database_name` | Target DB name |
| `DATABASE_USERNAME` | Secret `rds-sqlserver-instance-output` → `database_username` | RDS master username |
| `DATABASE_PASSWORD` | Secret `rds-sqlserver-instance-output` → `database_password` | RDS master password |
| `SQLSERVER_BACKUP_S3_BUCKET_NAME` | Secret `sqlserver-backup-s3-bucket-output` → `bucket_name` | Backup bucket |
| `CREATE_SNAPSHOT` | ConfigMap `rds-sqlserver-restore-config-map` → `create_snapshot` | `true`/`false` |
| `DATABASE_IDENTIFIER` | Secret `rds-sqlserver-instance-output` → `database_identifier` | RDS instance ID for snapshots |

**Restore process:**
1. Waits for SQL Server connectivity via port-forward (retries 30× at 10s intervals = max 5 mins)
2. Sets DB to `SINGLE_USER` to kill existing connections
3. Drops the existing database
4. Calls `msdb.dbo.rds_restore_database` — RDS pulls the `.bak` **directly from S3** (no file copy into pod)
5. Polls `rds_task_status` every 30s, times out after 60 minutes

---

## Service Pod — Manual Access

The `irsa-s3-cronjob-service-pod` (pod name: `irsa-s3-cronjob-service-pod-*`) runs permanently and uses the same `irsa-s3-cronjob` service account. Use it for manual AWS CLI investigation:

```bash
# Exec into the service pod
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod \
  exec -it irsa-s3-cronjob-service-pod-<hash> -- /bin/sh

# List upload bucket (NEC landing zone)
aws s3 ls s3://$(kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod \
  get secret upload-s3-bucket-output -o jsonpath='{.data.bucket_name}' | base64 -d)

# List backup bucket (internal .bak store)
aws s3 ls s3://$(kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod \
  get secret sqlserver-backup-s3-bucket-output -o jsonpath='{.data.bucket_name}' | base64 -d)
```

---

## Terraform Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `namespace` | `hmpps-manage-and-deliver-accredited-programmes-preprod` | K8s namespace |
| `environment` | `preprod` | Environment name |
| `is_production` | `false` | Production flag |
| `team_name` | `hmpps-accredited-programmes-manage-and-deliver-devs` | Team name tag |
| `business_unit` | `Platforms` | Business unit tag |
| `infrastructure_support` | `interventions-devs@digital.justice.gov.uk` | Support email |
| `logging_enabled` | `true` | S3 access logging on upload bucket |
| `log_path` | `logs/` | Prefix for log files in logging bucket |
| `db_allocated_storage` | `600` GB | RDS storage size |
| `db_engine` | `sqlserver-web` | RDS engine type |
| `db_engine_version` | `15.00.4345.5.v1` | SQL Server 2019 |
| `db_instance_class` | `db.m5.large` | RDS instance size |
| `db_backup_retention_period` | `0` | ⚠️ Automated RDS backups **disabled** |
| `sqlserver_restore_create_snapshot` | `true` | Pre-restore snapshot taken each night |
| `db_storage_type` | `gp2` | EBS storage type |

> **Note:** `db_backup_retention_period = 0` means AWS automated backups are off. The nightly manual snapshot (taken by the `create-rds-snapshot` init container) is the only backup mechanism before each restore.

---

## ⚠️ Known Issue — NEC Role Missing

**Problem:** NEC cannot upload files to `upload_s3_bucket`.

**Root cause:** The IAM role `arn:aws:iam::778742069978:role/im-preprod-s3-datasync` has been commented out of the bucket policy in `s3.tf` because **it does not exist** in NEC's AWS account `778742069978`. AWS will reject the entire bucket policy with `MalformedPolicy: Invalid principal` if a non-existent IAM ARN is referenced.

**History:**
| Date | Action | By |
|------|--------|-----|
| 2026-02-24 | Role commented out after causing Concourse deployment failures | TJWC |
| 2026-03-02 | Comment countersigned | RW |
| 2026-04-28 | Attempted re-enable, same error confirmed, reverted | RW |

**Resolution path:**
1. NEC must create the IAM role `im-preprod-s3-datasync` in AWS account `778742069978`
2. NEC must confirm creation
3. Uncomment the line in `s3.tf` and raise a PR — pipeline will apply cleanly

---

## 🔍 Troubleshooting Guide — "Why are no files arriving?"

Work through these checks in order:

### Step 1 — Is the upload bucket empty?
```bash
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod \
  exec -it irsa-s3-cronjob-service-pod-<hash> -- /bin/sh
aws s3 ls s3://<upload_bucket_name>
```
- **Empty + before 05:00 UTC** → NEC hasn't uploaded yet today, or their role is blocked (Step 2)
- **Empty + after 05:00 UTC** → cronjob ran and deleted files after sync — check backup bucket (Step 3)

### Step 2 — Is the NEC role enabled in the bucket policy?
Check `s3.tf` — look for:
```hcl
#"arn:aws:iam::778742069978:role/im-preprod-s3-datasync",
```
If commented out → NEC **cannot upload**. Chase NEC to confirm their role exists, then uncomment.

### Step 3 — Did files make it to the backup bucket?
```bash
aws s3 ls s3://<sqlserver_backup_bucket_name> --recursive | sort | tail -5
```
- Files present → transfer worked, DB restore may have consumed them
- Empty → S3 transfer cronjob failed, or NEC never uploaded

### Step 4 — Check the S3 transfer cronjob logs
```bash
# List recent job pods
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod get pods | grep s3-transfer

# Get logs from the most recent run
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod logs \
  hmpps-manage-and-deliver-acp-s3-transfer-<hash>
```
Look for: `Transfer completed successfully` or any AWS CLI errors (403, NoSuchBucket, etc.)

### Step 5 — Check the DB restore cronjob logs
```bash
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod get pods | grep db-restore
kubectl -n hmpps-manage-and-deliver-accredited-programmes-preprod logs \
  db-restore-cronjob-<hash> -c db-restore
```
Look for: `Restore completed successfully` or `No backup file found`

### Step 6 — Check S3 access logs
```bash
aws s3 ls s3://<logging_bucket_name>/logs/ --recursive | tail -20
```
Logs show all access attempts including 403 errors from NEC's role trying to write.

### Step 7 — Verify NEC's IAM role exists
Ask NEC to confirm:
- AWS Account: `778742069978`
- Role name: `im-preprod-s3-datasync`
- The role must have a trust policy allowing it to assume cross-account access to our bucket

### Common Error Messages

| Error | Meaning | Fix |
|-------|---------|-----|
| `MalformedPolicy: Invalid principal` | IAM role ARN in bucket policy doesn't exist in AWS | Comment out the non-existent role ARN |
| `403 Access Denied` (from NEC side) | NEC role not in bucket policy, or role doesn't exist | Re-enable role in bucket policy after NEC creates it |
| `No backup file found` (DB restore) | `sqlserver_backup_s3_bucket` is empty | S3 transfer didn't run or NEC didn't upload |
| `Timed out waiting for SQL Server` | Port-forward sidecar not ready | Check `db-port-forward-pod` is running |
| `Restore timed out after 60 minutes` | Large .bak file or RDS busy | Check RDS metrics, may need to increase timeout |

---

## Useful kubectl Commands

```bash
# Set namespace shortcut
NS=hmpps-manage-and-deliver-accredited-programmes-preprod

# Get all pods and their status
kubectl -n $NS get pods

# Get all cronjobs and their last schedule time
kubectl -n $NS get cronjobs

# Get all jobs (cronjob history)
kubectl -n $NS get jobs

# Describe a specific cronjob
kubectl -n $NS describe cronjob hmpps-manage-and-deliver-acp-s3-transfer
kubectl -n $NS describe cronjob db-restore-cronjob

# Get bucket names from secrets
kubectl -n $NS get secret upload-s3-bucket-output -o jsonpath='{.data.bucket_name}' | base64 -d
kubectl -n $NS get secret sqlserver-backup-s3-bucket-output -o jsonpath='{.data.bucket_name}' | base64 -d

# Manually trigger the S3 transfer cronjob (creates a one-off job)
kubectl -n $NS create job --from=cronjob/hmpps-manage-and-deliver-acp-s3-transfer manual-s3-transfer-$(date +%s)

# Manually trigger the DB restore cronjob
kubectl -n $NS create job --from=cronjob/db-restore-cronjob manual-db-restore-$(date +%s)
```

---

## File Locations

| Resource | File |
|----------|------|
| S3 bucket definitions + policies | `resources/s3.tf` |
| IRSA role definitions | `resources/irsa.tf` |
| Service pod | `resources/service_pod.tf` |
| Terraform variables | `resources/variables.tf` |
| S3 transfer cronjob | `cronjob-s3-transfer.yaml` |
| DB restore cronjob | `db_restore.yaml` |
| Namespace config | `00-namespace.yaml` |
| RBAC | `01-rbac.yaml` |
| Resource quota (max 50 pods) | `03-resourcequota.yaml` |
| Limit range (default 1 CPU / 1GB) | `02-limitrange.yaml` |

