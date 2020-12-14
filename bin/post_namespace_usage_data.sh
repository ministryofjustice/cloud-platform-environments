#!/bin/sh

bin/namespace-usage-reporter.rb -n '.*' -o json > namespace-usage.json

curl \
  --http1.1 \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: ${HOODAW_API_KEY}" \
  -d @namespace-usage.json \
  ${HOODAW_HOST}/namespace_usage
