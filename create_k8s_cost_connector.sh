#!/bin/bash

# OVERVIEW: The script below will create a k8s connector + cost access connector

# PREREQUISITES:
# - A delegate that can communicate with each masterURL needs to exist
# - This script runs through a list of pre-identified MasterURLs, cluster_names, etc.
# - A pre-created secret is used that references a service account token. We are referencing this service account to authorize the k8s connection within "account.YOURSECRETIDENTIFIER"
#        - Secret creation (Service account token) can also be achieved via our APIs: https://harness.io/docs/api/tag/Secrets#operation/postSecret

account_id="your_account_id"
#Token-creation docs: https://ngdocs.harness.io/article/tdoad7xrh9-add-and-manage-api-keys#create_personal_access_token 
token="your_harness_token"
SAtoken_id="account.YOURSECRETIDENTIFIER"
description="API provisioned k8s connectors"

#define list of masterUrls and names below:
declare -a master_url_array=("https://34.122.182.13" "masterurl2" "masterurl3")
declare -a cluster_name_array=("dank8sconnector1" "dank8sconnector2" "dank8sconnector3")
declare -a cluster_name_cost_array=("dank8sconnector1_costaccess" "dank8sconnector2_costaccess" "dank8sconnector3_costaccess")

len=${#master_url_array[@]}

#Loop through the array and setup a connector per masterURL 
for (( i=0; i<$len; i++ )); do 
#create generic_kubernetes_connectors based on MasterURL and ServiceAccount.
curl -i -X POST \
  'https://app.harness.io/gateway/ng/api/connectors?accountIdentifier='"$account_id"'' \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: '"$token"'' \
  -d '{
    "connector": {
      "name": "'"${cluster_name_array[$i]}"'",
      "identifier": "'"${cluster_name_array[$i]}"'",
      "description": "'"$description"'",
      "tags": {
        "property1": "string",
        "property2": "string"
      },
      "type": "K8sCluster",
      "spec": {
            "credential": {
              "type": "ManualConfig",
              "spec": {
                "masterUrl": "'"${master_url_array[$i]}"'",
                "auth": {
                  "type": "ServiceAccount",
                  "spec": {
                    "serviceAccountTokenRef": "'"$SAtoken_id"'",
                    "caCertRef": null
                  }
                }
              }
            }
    }
}  }'

#create kubernetes_cost_access connectors referencing the generic_k8s_connector
curl -i -X POST \
  'https://app.harness.io/gateway/ng/api/connectors?accountIdentifier='"$account_id"'' \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: '"$token"'' \
  -d '{
    "connector": {
      "name": "'"${cluster_name_cost_array[$i]}"'",
      "identifier": "'"${cluster_name_cost_array[$i]}"'",
      "description": "'"$description"'",
      "tags": {
        "property1": "string",
        "property2": "string"
      },
      "type": "CEK8sCluster",
      "spec": {
            "connectorRef": "'"${cluster_name_array[$i]}"'",
            "featuresEnabled": [
              "VISIBILITY"
            ]}  }
            
    }
}  }'; done


#Other items to tackle in the future: 
#1: Dynamically fetching list of MasterURLs from AKS, EKS, etc.
#2: Dynamically create/get SA tokens for each particular cluster

