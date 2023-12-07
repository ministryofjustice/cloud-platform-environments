#!/bin/bash

set -euo pipefail
cd namespaces/live.cloud-platform.service.justice.gov.uk
count=`ls -l | wc -l`
chunks=$((count / 5))
echo BATCHSIZW=$chunks

