GCLOUD_PROJECT:="ispa-176718"
DOCKER_USER="marjoram0"

create-cluster:
	gcloud container clusters create ispa --zone us-central1-a

create-bucket:
	gsutil mb gs://$(GCLOUD_PROJECT)
    gsutil defacl set public-read gs://$(GCLOUD_PROJECT)

delete:
	kubectl delete -f alltogether.yml
	gcloud sql instances patch isbadb --activation-policy NEVER

delete-cluster:
	gcloud container clusters delete ispa
