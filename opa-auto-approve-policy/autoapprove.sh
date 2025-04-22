#!/usr/bin/env bash
set -eu

PLAN_DIR=$1
PLAN_NAME=$2
PR=$3

JSON_FILE="${PLAN_NAME%.out}.json"

terraform -chdir="$PLAN_DIR" show -json "$PLAN_NAME" > "$JSON_FILE"

results=()

for dir in opa-auto-approve-policy/*/;
do
    OUTPUT=$(opa exec --decision terraform/analysis/allow --bundle $dir "$JSON_FILE")
    OPA_RESULT=$(echo "$OUTPUT" | jq -r '.result[0].result.valid')
    OPA_MESSAGE=$(echo "$OUTPUT" | jq -r '.result[0].result.msg')
    testname=$(echo "$dir" | sed 's/opa\-auto\-approve\-policy\///g' | sed 's/\///g')
    if [[ $OPA_RESULT == "true" ]]
    then
      testresult=":white_check_mark:"
    else
      testresult=":x:"
    fi
    results+=($testname";"$testresult";""$OPA_MESSAGE")

done

CHANGED_FILES=$(curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/ministryofjustice/cloud-platform-environments/pulls/$PR/files" |  jq -r '.[].filename')


NUM_CHANGED_FILES=$(echo "$CHANGED_FILES" | wc -l)

if [[ "$CHANGED_FILES" == namespaces/live.cloud-platform.service.justice.gov.uk/*/APPLY_PIPELINE_SKIP_THIS_NAMESPACE ]] && [[ "$NUM_CHANGED_FILES" -eq 1 ]] ; then
    exit 0
fi

YAML_CHANGES=0
for f in $CHANGED_FILES; do
    if [[ "$f" == namespaces/live.cloud-platform.service.justice.gov.uk/*/*.yaml ]]; then
        YAML_CHANGES=1
        break
    fi
done

if [[ ${results[@]} =~ ":x:" ]] && [ "$YAML_CHANGES" -eq 0 ];
then
  REASON=":male_detective: **Manual review required: [OPA auto approve policy](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/opa-auto-approve-policy) checks did not pass.**"

  string="\n| Test | Passed? | Reason | \n| --- | --- | --- |\n|"
  for t in "${results[@]}"; do
    split=$(echo "$t" | tr ";" "|")
    for th in "$split"
    do
      string+=" $th |"
    done
    string+="\n"
  done

  REASON+=$string

  if [ "$YAML_CHANGES" -ne 0 ]; then
      if [ -n "$REASON" ]; then
          REASON="$REASON\n:male_detective: **Detected changes to K8s YAML files. Manual review needed.**"
      else
          REASON=":male_detective: **Detected changes to K8s YAML files. Manual review needed.**"
      fi
  fi

  curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/ministryofjustice/cloud-platform-environments/issues/$PR/comments" \
  -d '{
      "body": "This PR **CANNOT** be auto approved and requires manual approval from the Cloud Platform team.\n Reason:\n '"$REASON"'\n Please raise it in #ask-cloud-platform Slack channel."
  }'
else
  curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/ministryofjustice/cloud-platform-environments/pulls/$PR/reviews" \
  -d '{
    "body": ":white_check_mark: **Auto-Approved!**\n\nThis PR has **passed the [OPA auto approve policy](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/opa-auto-approve-policy) check and security validation**.\n\nYou can merge whenever suits you! :rocket:",
    "event": "APPROVE"
  }'
fi

exit 0
