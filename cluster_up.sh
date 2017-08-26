#!/bin/bash
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
# # Unless required by applicable law or agreed to in writing, software # distributed under the License is distributed on an "AS IS" BASIS, # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions

#	gsutil mb gs://<bucket>
# gsutil defacl set public-read gs://<bucket>

set -e

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

# Check for cluster name as first (and only) arg
CLUSTER_NAME=$1
NUM_NODES=2
NETWORK=default
ZONE=us-central1-b

gcloud components update --quiet

# patch postgres instance to ensure its running
gcloud sql instances patch isbadbase --activation-policy ALWAYS

gcloud iam service-accounts list|grep "ISBA DB Service Account" > /dev/null
if [ $? == 1]; then
  gcloud iam service-accounts create isba-db --display-name "Marjoram Digital DB Service Account"
  gcloud projects add-iam-policy-binding coherent-window-177723 --member serviceAccount:isba-db@coherent-window-177723.iam.gserviceaccount.com --role roles/cloudsql.client
  gcloud projects add-iam-policy-binding coherent-window-177723 --member serviceAccount:isba-db@coherent-window-177723.iam.gserviceaccount.com --role roles/storage.objectViewer
  gcloud iam service-accounts keys create credentials.json --iam-account isba-db@coherent-window-177723.iam.gserviceaccount.com
fi

gcloud container clusters create ${CLUSTER_NAME} \
  --num-nodes ${NUM_NODES} \
  --scopes "https://www.googleapis.com/auth/projecthosting,https://www.googleapis.com/auth/devstorage.full_control,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/cloud-platform" \
  --zone ${ZONE} \
  --network ${NETWORK} || error_exit "error creating cluster"

# Make kubectl use new cluster
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}

kubectl create secret generic cloudsql-oauth-credentials --from-file=credentials.json=secrets/cloudsql/credentials.json
kubectl create secret generic cloudsql --from-literal=username=dev --from-literal=password=justtestit

kubectl create -f sqlproxy/postgres-proxy.yml
kubectl create -f sqlproxy/proxy-service.yml
echo "wait for postgres"
while :
  do kubectl get pods -lapp=postgres-proxy -o=custom-columns=STATUS=.status.phase 2> /dev/null|grep Running > /dev/null
  if [ $? == 0 ]; then
    break
  fi
  sleep 30
done

# ./manage.py collectstatic
# gsutil rsync -R static/ gs:<bucket>/static/

kubectl create -f isba/isba.yml
kubectl create -f isba/isba-service.yml


echo "done."
