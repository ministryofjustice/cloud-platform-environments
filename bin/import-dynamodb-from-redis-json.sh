#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bin/common.sh
source "${SCRIPT_DIR}/common.sh"

usage() {
  cat <<'EOF'
Usage:
  import-dynamodb-from-redis-json.sh \
    --namespace <k8s-namespace> \
    --info-file <path/to/info.json> \
    --health-file <path/to/health.json> \
    --version-file <path/to/version.json> \
    [--region eu-west-2] \
    [--info-table <table-name>] \
    [--health-table <table-name>] \
    [--version-table <table-name>] \
    [--max-item-bytes 380000] \
    [--dry-run]

Notes:
- If table names are not provided, they are resolved from Kubernetes secrets in the namespace:
  - hmpps-portfolio-management-info-dynamodb-output
  - hmpps-portfolio-management-health-dynamodb-output
  - hmpps-portfolio-management-version-dynamodb-output
- Uses Redis stream id first part as recorded_at_epoch (milliseconds).
- Skips oversized request items and records them in a skip log.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log red "Missing required command: $1"
    exit 1
  fi
}

NAMESPACE=""
REGION="eu-west-2"
INFO_FILE=""
HEALTH_FILE=""
VERSION_FILE=""
INFO_TABLE=""
HEALTH_TABLE=""
VERSION_TABLE=""
MAX_ITEM_BYTES=380000
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --namespace)
      NAMESPACE="$2"; shift 2 ;;
    --region)
      REGION="$2"; shift 2 ;;
    --info-file)
      INFO_FILE="$2"; shift 2 ;;
    --health-file)
      HEALTH_FILE="$2"; shift 2 ;;
    --version-file)
      VERSION_FILE="$2"; shift 2 ;;
    --info-table)
      INFO_TABLE="$2"; shift 2 ;;
    --health-table)
      HEALTH_TABLE="$2"; shift 2 ;;
    --version-table)
      VERSION_TABLE="$2"; shift 2 ;;
    --max-item-bytes)
      MAX_ITEM_BYTES="$2"; shift 2 ;;
    --dry-run)
      DRY_RUN="true"; shift 1 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      log red "Unknown argument: $1"
      usage
      exit 1 ;;
  esac
done

if [[ -z "$NAMESPACE" || -z "$INFO_FILE" || -z "$HEALTH_FILE" || -z "$VERSION_FILE" ]]; then
  log red "Missing required arguments."
  usage
  exit 1
fi

require_cmd jq
require_cmd aws
require_cmd kubectl

for f in "$INFO_FILE" "$HEALTH_FILE" "$VERSION_FILE"; do
  if [[ ! -f "$f" ]]; then
    log red "File not found: $f"
    exit 1
  fi
done

resolve_table_from_secret() {
  local namespace="$1"
  local secret_name="$2"

  kubectl -n "$namespace" get secret "$secret_name" -o jsonpath='{.data.table_name}' | base64 --decode
}

if [[ -z "$INFO_TABLE" ]]; then
  INFO_TABLE="$(resolve_table_from_secret "$NAMESPACE" "hmpps-portfolio-management-info-dynamodb-output")"
fi
if [[ -z "$HEALTH_TABLE" ]]; then
  HEALTH_TABLE="$(resolve_table_from_secret "$NAMESPACE" "hmpps-portfolio-management-health-dynamodb-output")"
fi
if [[ -z "$VERSION_TABLE" ]]; then
  VERSION_TABLE="$(resolve_table_from_secret "$NAMESPACE" "hmpps-portfolio-management-version-dynamodb-output")"
fi

log blue "Namespace: $NAMESPACE"
log blue "Region: $REGION"
log blue "Info table: $INFO_TABLE"
log blue "Health table: $HEALTH_TABLE"
log blue "Version table: $VERSION_TABLE"
log blue "Max item bytes: $MAX_ITEM_BYTES"
log blue "Dry run: $DRY_RUN"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

jq_filter='def clean_token:
  gsub("^[[:space:]\\\"\047\\[]+"; "") | gsub("[[:space:]\\\"\047\\]]+$"; "");

def parse_service_env($k):
  if ($k | startswith("version:")) then
    {
      service: ($k | split(":") | .[1] // "unknown-service"),
      environment: ($k | split(":") | .[2] // "unknown-env")
    }
  else
    {
      service: ($k | split(":") | .[1] // "unknown-service"),
      environment: (
        ($k | capture("\\[(?<arr>.*)\\]$").arr? // "")
        | split(",")
        | map(clean_token)
        | (.[-1] // "unknown-env")
      )
    }
  end;

def kv_to_obj($a):
  reduce range(0; ($a | length); 2) as $i ({}; . + { ($a[$i]): ($a[$i + 1] // "") });

.[] as $grp
| (parse_service_env($grp.key)) as $se
| $grp.data[] as $entry
| ($entry[0] // "") as $stream_id
| ($stream_id | split("-") | .[0] | tonumber?) as $epoch
| select($epoch != null)
| (kv_to_obj($entry[1])) as $kv
| {
    PutRequest: {
      Item: {
        service_environment: {S: ($se.service + "#" + $se.environment)},
        recorded_at_epoch: {N: ($epoch | tostring)},
        service: {S: $se.service},
        environment: {S: $se.environment},
        stream_id: {S: $stream_id},
        date_added: {S: ($kv.dateAdded // "")},
        url: {S: ($kv.url // "")},
        http_s: (if ($kv.http_s // "") | test("^[0-9]+$") then {N: $kv.http_s} else {S: ($kv.http_s // "")} end),
        error: {S: ($kv.error // "")},
        v: {S: ($kv.v // "")},
        git_compare: {S: ($kv.git_compare // "")},
        payload_json: {S: ($kv | tojson)}
      }
    }
  }'

flush_batch() {
  local table_name="$1"
  local batch_file="$2"

  if [[ ! -s "$batch_file" ]]; then
    return 0
  fi

  local req_file="$TMP_DIR/request.json"
  local resp_file="$TMP_DIR/response.json"
  jq -s --arg table "$table_name" '{RequestItems: {($table): .}}' "$batch_file" > "$req_file"

  if [[ "$DRY_RUN" == "true" ]]; then
    log green "Dry run: would write $(jq 'length' "$batch_file") items to table $table_name"
    : > "$batch_file"
    return 0
  fi

  local attempt=0
  local max_attempts=8

  while :; do
    aws dynamodb batch-write-item \
      --region "$REGION" \
      --request-items "file://$req_file" > "$resp_file"

    local remaining
    remaining="$(jq --arg table "$table_name" '.UnprocessedItems[$table] | length // 0' "$resp_file")"

    if [[ "$remaining" == "0" ]]; then
      break
    fi

    attempt=$((attempt + 1))
    if (( attempt > max_attempts )); then
      log red "Exceeded retries with $remaining unprocessed items for table $table_name"
      jq --arg table "$table_name" '.UnprocessedItems[$table]' "$resp_file" > "$TMP_DIR/unprocessed-${table_name}.json"
      break
    fi

    log blue "Retry $attempt for $remaining unprocessed items in table $table_name"
    jq --arg table "$table_name" '{RequestItems: {($table): (.UnprocessedItems[$table] // [])}}' "$resp_file" > "$req_file"
    sleep $((2 ** attempt))
  done

  : > "$batch_file"
}

import_file() {
  local kind="$1"
  local file_path="$2"
  local table_name="$3"

  log green "Preparing $kind items from $file_path"

  local lines_file="$TMP_DIR/${kind}-items.ndjson"
  local batch_file="$TMP_DIR/${kind}-batch.ndjson"
  local skip_file="$TMP_DIR/${kind}-skipped.ndjson"

  jq -c "$jq_filter" "$file_path" > "$lines_file"

  local total=0
  local queued=0
  local skipped=0
  local line_size=0

  : > "$batch_file"
  : > "$skip_file"

  while IFS= read -r line; do
    total=$((total + 1))
    line_size="$(printf '%s' "$line" | wc -c | tr -d ' ')"

    if (( line_size > MAX_ITEM_BYTES )); then
      skipped=$((skipped + 1))
      printf '%s\n' "$line" >> "$skip_file"
      continue
    fi

    printf '%s\n' "$line" >> "$batch_file"
    queued=$((queued + 1))

    if (( queued % 25 == 0 )); then
      flush_batch "$table_name" "$batch_file"
    fi
  done < "$lines_file"

  flush_batch "$table_name" "$batch_file"

  log green "$kind complete: total=$total queued=$queued skipped_oversize=$skipped"
  if (( skipped > 0 )); then
    log blue "$kind skipped items saved to: $skip_file"
  fi
}

import_file "info" "$INFO_FILE" "$INFO_TABLE"
import_file "health" "$HEALTH_FILE" "$HEALTH_TABLE"
import_file "version" "$VERSION_FILE" "$VERSION_TABLE"

log green "All imports finished."
