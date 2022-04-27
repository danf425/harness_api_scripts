#!/bin/bash
account_id="your_account_id"
token="your_harness_token"
description="API provisioned k8s connectors"

#pending-items: 
#1: how to dynamically get a list of all MasterURLs from AKS
#2: how to dynamically get service account tokens for each particular cluster

#define list of masterUrls and names below:
declare -a masterUrlArray=("https://34.122.182.13" "masterurl2" "masterurl3")
declare -a cluster_name_array=("dank8sconnector1" "dank8sconnector2" "dank8sconnector3")
declare -a cluster_name_cost_array=("dank8sconnector1_costaccess" "dank8sconnector2_costaccess" "dank8sconnector3_costaccess")

len=${#masterUrlArray[@]}
for (( i=0; i<$len; i++ )); do 
#create generic_kubernetes_connectors based on MasterURL and ServiceAccount
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
                "masterUrl": "'"${masterUrlArray[$i]}"'",
                "auth": {
                  "type": "ServiceAccount",
                  "spec": {
                    "serviceAccountTokenRef": "account.danfcluster2satoken",
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


