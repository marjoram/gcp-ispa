# gcp-ispa
Kubernetes setup for deploying ISPA on Google Cloud Platform

Redis cluster:

```
kubectl apply -f redis/alltogether.yml
```

Postgres:

```
gcloud compute disks create pg-data --size 20GB
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

Migrations:

```
kubectl exec <pod> -- python manage.py migrate --no-input
```

Delete clusters and data:

```
gcloud container clusters delete <ispa>
gcloud compute disks delete pg-data
```
