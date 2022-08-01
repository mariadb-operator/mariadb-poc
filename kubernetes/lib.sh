#!/bin/bash

set -e

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
HOSTNAME=$(hostname)
STATEFULSET_INDEX=${HOSTNAME##*-}
STATEFULSET_NAME=${HOSTNAME%-*}

is_initialized() {
  [ ! -z "$(ls -A /var/lib/mysql)" ]
}

get_new_cluster() {
  WSREP_NEW_CLUSTER="OFF"
  if [ "$STATEFULSET_INDEX" = "0" ] && ! $(is_initialized); then
      WSREP_NEW_CLUSTER="ON"
  fi
  if [ "$BOOSTRAP_CLUSTER" ]; then
      WSREP_NEW_CLUSTER="ON"
  fi
  echo $WSREP_NEW_CLUSTER
}

get_statefulset() {
  STATEFULSET_URL="https://kubernetes/apis/apps/v1/namespaces/$POD_NAMESPACE/statefulsets/$STATEFULSET_NAME"
  echo $(curl "$STATEFULSET_URL" -H "Authorization: Bearer $TOKEN" --cacert "$CA_CERT")
}

get_all_pods_cluster_address() {
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

get_ready_pods_cluster_address() {
  PODS_URL="https://kubernetes/api/v1/namespaces/$POD_NAMESPACE/pods"
  PODS=$(
    curl "$PODS_URL" -H "Authorization: Bearer $TOKEN" --cacert "$CA_CERT" | \
      jq -r ".items[] | \
      select(.metadata.name | startswith(\"$STATEFULSET_NAME-\")) | \
      select(.status.containerStatuses[0].ready == true) | \
      .metadata.name"
  )
  PODS=(
    $PODS
  )
  STATEFULSET=$(get_statefulset)
  HEADLESS_SERVICE=$(echo $STATEFULSET | jq -r '.spec.serviceName')

  GALERA_CLUSTER_ADDRESS="gcomm://"

  # TODO: this is only valid in a 3 node cluster. Do it dynamically
  if [[ "${#PODS[@]}" -lt "2" ]]; then
    echo "$GALERA_CLUSTER_ADDRESS"
    return
  fi

  for i in "${PODS[@]}"
  do 
    GALERA_CLUSTER_ADDRESS="$GALERA_CLUSTER_ADDRESS$i.$HEADLESS_SERVICE.$POD_NAMESPACE.svc.$CLUSTER,"
  done
  GALERA_CLUSTER_ADDRESS="$GALERA_CLUSTER_ADDRESS$HOSTNAME.$HEADLESS_SERVICE.$POD_NAMESPACE.svc.$CLUSTER"

  echo $GALERA_CLUSTER_ADDRESS
}

get_cluster_address() {
  if ! $(is_initialized); then 
    echo $(get_all_pods_cluster_address)
    return
  fi
  echo $(get_ready_pods_cluster_address)
}
