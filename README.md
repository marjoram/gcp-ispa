# gcp-ispa
Kubernetes setup for deploying ISPA on Google Cloud Platform


Create a container cluster:

```
gcloud container clusters create ispa --num-nodes 2 --zone us-central1-a
# Once its created, get the credentials for kubectl
gcloud container clusters get-credentials ispa --zone us-central1-a
```

Create database secrets:

```
kubectl create secret generic cloudsql --from-literal=username=[PROXY_USERNAME] --from-literal=password=[PASSWORD]
kubectl create secret generic cloudsql-oauth-credentials --from-file=credentials.json=[PATH_TO_CREDENTIAL_FILE]
```

Create a new [database](https://cloud.google.com/sql/docs/postgres/create-manage-databases#create) and [user](https://cloud.google.com/sql/docs/postgres/create-manage-users#creating) on the [GP console]()

Set the password for the `postgres` user:

```
gcloud sql users set-password postgres no-host --instance=[INSTANCE_NAME] \
       --password=[PASSWORD]
```


Serve static through GCS:

```
gsutil mb gs://<ispa>
gsutil defacl set public-read gs://<ispa>
```

Collect into static/ folder:

```
python manage.py collectstatic
```

Upload to cloudstorage:

```
gsutil rsync -R static/ gs://<gcs-bucke>/static
```

CDN will be at:

```
http://storage.googleapis.com/<gcs-bucket>/static/
```
