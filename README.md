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
```

push the docker image to googles cr:

```
docker build -t gcr.io/<your-project-id>/ispa:latest .
gcloud docker -- push gcr.io/<your-project-id>/ispa:latest
```

Create kubernetes resource:

```
kubectl create -f ispa.yml
```

Redis cluster:

```
kubectl apply -f redis/alltogether.yml
```

Postgres:

Create a Google Cloud SQL Postgres instance:

```
gcloud sql instances create myinstance --cpu=1 --memory=3840MiB \
        --database-version=POSTGRES_9_6
```

Get the connection name:

```
gcloud sql instances describe [YOUR_INSTANCE_NAME]
```

Start the sql proxy
```
./cloud_sql_proxy -instances="[YOUR_INSTANCE_CONNECTION_NAME]"=tcp:5432
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

Delete clusters and data:

```
gcloud container clusters delete <ispa>
```
