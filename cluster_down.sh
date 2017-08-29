#!/bin/bash
DEPLOYMENT=$1

if [ "DEPLOYMENT" == "" ]; then
  echo "Needs deployment name"
  exit 2
fi

kubectl delete -f isba/isba-service.yml

gcloud sql instances patch ${DEPLOYMENT} --activation-policy NEVER
gcloud container clusters delete ${DEPLOYMENT} --quiet
