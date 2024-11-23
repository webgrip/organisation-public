#!/bin/bash

CLUSTER_NAME=$1
REGION=$2

if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ]; then
  echo "Usage: ./set-kubeconfig.sh <cluster_name> <region>"
  exit 1
fi

aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
