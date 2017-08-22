#!/bin/bash
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
# # Unless required by applicable law or agreed to in writing, software # distributed under the License is distributed on an "AS IS" BASIS, # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
set -e

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

# Check for cluster name as first (and only) arg
CLUSTER_NAME=$1
NUM_NODES=1
NETWORK=default
ZONE=us-central1-a

gcloud components update --quiet

# Source the config
if ! gcloud container clusters describe ${CLUSTER_NAME} > /dev/null 2>&1; then
  echo "creating gcp container engine cluster \"${CLUSTER_NAME}\"..."
  # Create cluster
  gcloud container clusters create ${CLUSTER_NAME} \
    --num-nodes ${NUM_NODES} \
    --scopes "https://www.googleapis.com/auth/projecthosting,https://www.googleapis.com/auth/devstorage.full_control,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/cloud-platform" \
    --zone ${ZONE} \
    --network ${NETWORK} || error_exit "error creating cluster"
else
  echo "* gce cluster \"${CLUSTER_NAME}\" already exists..."
fi

# Make kubectl use new cluster
echo "configuring kubectl to use ${CLUSTER_NAME} cluster..."
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}

echo "creating postgresql database"
gcloud sql instances patch isbadb --activation-policy ALWAYS

# Create static files bucket via Make, rsync static/ folder
#gsutil rsync -R static/ gs://<your-gcs-bucket>/static

kubectl create secret generic cloudsql-oauth-credentials --from-file=credentials.json=secrets/cloudsql/creds.json
kubectl create secret generic cloudsql --from-literal=username=postgres --from-literal=password=justtestit
kubectl apply -f alltogether.yml
echo "done."
