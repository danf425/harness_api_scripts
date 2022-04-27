#!/bin/bash
account_id="your_account_id"
token="your_token"
curl -i -X GET \
  'https://app.harness.io/gateway/ng/api/connectors?pageIndex=0&pageSize=100&accountIdentifier='"$account_id"'&searchTerm=danf-cluster-2&getDefaultFromOtherRepo=true' \
  -H 'x-api-key: '"$token"''