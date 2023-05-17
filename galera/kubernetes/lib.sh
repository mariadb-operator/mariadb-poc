#!/bin/bash

set -e

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
HOSTNAME=$(hostname)
STATEFULSET_INDEX=${HOSTNAME##*-}
STATEFULSET_NAME=${HOSTNAME%-*}

get_new_cluster() {
  WSREP_NEW_CLUSTER="OFF"
  if [ "$STATEFULSET_INDEX" = "0" ] && ! $(is_initialized); then
      WSREP_NEW_CLUSTER="ON"
  fi
  echo $WSREP_NEW_CLUSTER
}

get_statefulset() {
  STATEFULSET_URL="https://kubernetes/apis/apps/v1/namespaces/$POD_NAMESPACE/statefulsets/$STATEFULSET_NAME"
  echo $(curl "$STATEFULSET_URL" -H "Authorization: Bearer $TOKEN" --cacert "$CA_CERT")
}

get_cluster_address() {
  STATEFULSET=$(get_statefulset)
  REPLICAS=$(echo $STATEFULSET | jq -r '.spec.replicas')
  HEADLESS_SERVICE=$(echo $STATEFULSET | jq -r '.spec.serviceName')

  GALERA_CLUSTER_ADDRESS="gcomm://"
  for (( i=0; i<$REPLICAS; i++ ))
  do 
    GALERA_CLUSTER_ADDRESS="$GALERA_CLUSTER_ADDRESS$STATEFULSET_NAME-$i.$HEADLESS_SERVICE.$POD_NAMESPACE.svc.$CLUSTER,"
  done
  echo ${GALERA_CLUSTER_ADDRESS%,*}
}
