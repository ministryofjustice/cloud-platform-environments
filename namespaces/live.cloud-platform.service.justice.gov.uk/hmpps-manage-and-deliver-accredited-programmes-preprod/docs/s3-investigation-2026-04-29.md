# S3 Pipeline Investigation — 2026-04-29
**Investigator:** RW  
**Namespace:** `hmpps-manage-and-deliver-accredited-programmes-preprod`

---

## Summary of Findings

The S3 transfer pipeline is **partially working but critically broken**:

- ✅ NEC **are** uploading files successfully (using `im-production-s3-datasync`)
- ✅ The S3 transfer cronjob **has been syncing** files to the backup bucket
- ❌ Today's S3 transfer cronjob **failed 4 times** (3× Error, 1× ContainerStatusUnknown)
- ⚠️ The backup bucket is **accumulating ALL historical files** — the DB restore is NOT consuming/clearing them
- ⚠️ The upload bucket still has files in it today — confirming today's transfer failed

---

## Timeline Reconstruction

### What we found in the upload bucket (`cloud-platform-421f9ae70e6559d242c61fe413ef46a4`)
46 `.bak` files dating from **2026-03-06 to 2026-04-29** — all with `2026-04-29` last-modified timestamps, meaning they were all there when we looked and **were not deleted by today's failed cronjob**.

### What we found in the backup bucket (`cloud-platform-e383febcb9837cc63850a33281750c47`)

| File | Uploaded to backup bucket | Notes |
|------|--------------------------|-------|
| `IM_Prod_29_10_2025.bak` | 2026-02-17 | Very old — from before pipeline existed |
| `backup-IM-dbo-only-20260305094425.bak` | 2026-03-31 | Early pipeline test |
| `I AM A TEST FILE#3.txt` | 2026-03-31 | Test files |
| `IAMATESTFILE2.txt` | 2026-03-31 | Test files |
| `I_AM_A_TEST_FILE1.txt` | 2026-03-31 | Test files |
| `testfile.txt` | 2026-03-31 | Test file |
| `backup-production-IM-dbo-only-20260306*.bak` through `20260429*.bak` | 2026-04-27 to 2026-04-29 | **All synced successfully on previous days** |

### Key observation — backup bucket timestamps
The backup bucket timestamps show files were synced on **2026-04-27 and 2026-04-28** successfully. Today (2026-04-29) the cronjob failed before it could sync new files or delete old ones from the upload bucket.

---

## Today's Failure — S3 Transfer CronJob

```
hmpps-manage-and-deliver-acp-s3-transfer-29623980-dmp22  ContainerStatusUnknown  (5h51m ago)
hmpps-manage-and-deliver-acp-s3-transfer-29623980-nh4qx  Error                   (5h46m ago)
hmpps-manage-and-deliver-acp-s3-transfer-29623980-fplkv  Error                   (5h25m ago)
hmpps-manage-and-deliver-acp-s3-transfer-29623980-5l57f  Error                   (5h28m ago)
```

All 4 attempts (`backoffLimit: 3` = 4 total tries) failed. Container logs were unrecoverable:
```
unable to retrieve container logs for containerd://7b64efb99eb6f0d5268c232b0f595745f6e7395149ad0810f12845e5b045320b
```

This indicates the container was **OOMKilled or evicted** before it could write logs — the files in the upload bucket are ~32-35GB each. Syncing 46 files × ~34GB = **~1.5TB of data** in a single run.

### Root cause hypothesis — volume of data
The cronjob uses `aws s3 sync` which syncs **every file that doesn't exist in the destination**. Because the backup bucket already has most of the files, previous runs only needed to copy 1-2 new files. But today something caused it to try to re-sync a large batch, hitting a resource or time limit.

---

## Critical Issue — DB Restore NOT Running on New Files

Looking at the backup bucket, files go back to **February 2026** and are never cleaned up. The DB restore cronjob (`db-restore-cronjob`) picks the **latest file by sort order** — so it should be working on the most recent `.bak`. 

However the accumulation of files suggests either:
1. The DB restore **is** running but doesn't delete files after restore (by design — RDS restore doesn't clean S3)
2. We should check the DB restore logs to confirm it's actually completing successfully

---

## Commands Run During Investigation

```bash
# 1. Confirmed upload bucket name
NS=hmpps-manage-and-deliver-accredited-programmes-preprod
UPLOAD_BUCKET=$(kubectl -n $NS get secret upload-s3-bucket-output \
  -o jsonpath='{.data.bucket_name}' | base64 -d)
# Result: cloud-platform-421f9ae70e6559d242c61fe413ef46a4

# 2. Confirmed backup bucket name
BACKUP_BUCKET=$(kubectl -n $NS get secret sqlserver-backup-s3-bucket-output \
  -o jsonpath='{.data.bucket_name}' | base64 -d)
# Result: cloud-platform-e383febcb9837cc63850a33281750c47

# 3. Listed upload bucket — found 46 .bak files + test.bak we uploaded
kubectl -n $NS exec -it irsa-s3-cronjob-service-pod-64b878d66-pz4c9 -- /bin/sh
aws s3 ls s3://cloud-platform-421f9ae70e6559d242c61fe413ef46a4
# Result: 46 .bak files, dates 2026-03-06 to 2026-04-29

# 4. Checked recent s3-transfer job pods
kubectl -n $NS get pods | grep s3-transfer
# Result: last 2 runs Completed (29619660, 29622540), today's run (29623980) failed 4 times

# 5. Attempted to get logs — unrecoverable
kubectl -n $NS logs hmpps-manage-and-deliver-acp-s3-transfer-29623980-fplkv
# Result: unable to retrieve container logs

# 6. Listed backup bucket
aws s3 ls s3://cloud-platform-e383febcb9837cc63850a33281750c47
# Result: files from 2026-02-17 through 2026-04-29 (see table above)
```

---

## Next Steps — Immediate Actions

### 1. Check DB restore logs (to confirm it's working)
```bash
NS=hmpps-manage-and-deliver-accredited-programmes-preprod
kubectl -n $NS get pods | grep db-restore
kubectl -n $NS logs db-restore-cronjob-<latest-hash> -c db-restore
```
Look for `Restore completed successfully` or errors.

### 2. Investigate why today's S3 transfer failed
The `ContainerStatusUnknown` followed by 3 `Error` states with unrecoverable logs strongly suggests an OOM kill or node eviction. Check:
```bash
kubectl -n $NS describe pod hmpps-manage-and-deliver-acp-s3-transfer-29623980-dmp22
```
Look for `OOMKilled`, `Evicted`, or `Error` in the Events section.

### 3. Consider adding a file retention/cleanup policy to the backup bucket
The backup bucket has files going back to February — the DB restore only ever uses the **latest** file. All older files are wasted storage. Consider adding an S3 lifecycle policy to delete files older than e.g. 7 days.

### 4. Consider limiting the sync to only new files
The `aws s3 sync` command checks every file every run. With 46 × ~34GB files, even listing and checking takes time. Consider using a date-based prefix or only syncing the most recent file.

---

## Bucket Contents at Time of Investigation

### Upload bucket (`cloud-platform-421f9ae70e6559d242c61fe413ef46a4`) — 46 .bak files

All with `2026-04-29` last-modified (NEC uploads daily, today's cronjob failed to delete them):

| File | Size | NEC Upload Date (from filename) |
|------|------|---------------------------------|
| `backup-production-IM-dbo-only-20260306124708.bak` | 32.9 GB | 2026-03-06 |
| `backup-production-IM-dbo-only-20260314023413.bak` | 32.1 GB | 2026-03-14 |
| `backup-production-IM-dbo-only-20260316023514.bak` | 32.1 GB | 2026-03-16 |
| `backup-production-IM-dbo-only-20260317022912.bak` | 32.1 GB | 2026-03-17 |
| `backup-production-IM-dbo-only-20260318022812.bak` | 32.1 GB | 2026-03-18 |
| `backup-production-IM-dbo-only-20260319022911.bak` | 32.1 GB | 2026-03-19 |
| `backup-production-IM-dbo-only-20260320023013.bak` | 32.1 GB | 2026-03-20 |
| `backup-production-IM-dbo-only-20260321023312.bak` | 32.1 GB | 2026-03-21 |
| `backup-production-IM-dbo-only-20260322023914.bak` | 32.1 GB | 2026-03-22 |
| `backup-production-IM-dbo-only-20260323023313.bak` | 32.1 GB | 2026-03-23 |
| `backup-production-IM-dbo-only-20260324023212.bak` | 32.1 GB | 2026-03-24 |
| `backup-production-IM-dbo-only-20260325022811.bak` | 32.1 GB | 2026-03-25 |
| `backup-production-IM-dbo-only-20260326022912.bak` | 32.1 GB | 2026-03-26 |
| `backup-production-IM-dbo-only-20260327022911.bak` | 32.1 GB | 2026-03-27 |
| `backup-production-IM-dbo-only-20260328023413.bak` | 32.1 GB | 2026-03-28 |
| `backup-production-IM-dbo-only-20260330013612.bak` | 32.1 GB | 2026-03-30 |
| `backup-production-IM-dbo-only-20260331013112.bak` | 32.1 GB | 2026-03-31 |
| `backup-production-IM-dbo-only-20260401013612.bak` | 32.1 GB | 2026-04-01 |
| ... (continues daily) | ~32 GB each | ... |
| `backup-production-IM-dbo-only-20260429012910.bak` | 32.2 GB | 2026-04-29 |
| `test.bak` | 26 bytes | Added by RW during investigation |

**Total upload bucket size: ~46 × ~32GB = ~1.47 TB**

### Backup bucket (`cloud-platform-e383febcb9837cc63850a33281750c47`)

Contains same files plus older ones from before the `backup-production-*` naming convention.

---

## Conclusions

| Finding | Impact | Action Required |
|---------|--------|-----------------|
| NEC is uploading daily using `im-production-s3-datasync` | ✅ Good — files arrive | None — but preprod role still needs creating |
| S3 transfer cronjob worked previously (Apr 27-28) | ✅ Good | None |
| Today's S3 transfer failed (all 4 attempts, no logs) | ❌ Files not moved/deleted today | Investigate OOMKill via `kubectl describe pod` |
| ~1.5TB of files queued in upload bucket | ⚠️ Next sync will try to copy everything it hasn't seen yet | Add lifecycle policy to both buckets |
| Backup bucket has files back to Feb 2026 | ⚠️ Wasted storage, growing daily | Add S3 lifecycle policy (e.g. keep 7 days) |
| DB restore cronjob status unknown | ❓ May or may not be restoring correctly | Check `db-restore-cronjob` logs |

