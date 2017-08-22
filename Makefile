GCLOUD_PROJECT:="ispa-176718"
DOCKER_USER="marjoram0"

create-cluster:
	gcloud container clusters create ispa --zone us-central1-a

create-bucket:
	gsutil mb gs://$(GCLOUD_PROJECT)
    gsutil defacl set public-read gs://$(GCLOUD_PROJECT)

delete:
	kubectl delete -f ispa-app.yml
	kubectl delete deployment ispa
	kubectl delete service ispa
<<<<<<< HEAD
	gcloud container clusters delete ispa
	gcloud sql instances patch ispadb --activation-policy NEVER
=======
>>>>>>> 3c21d1c08add74afc6da4bf8185eb69dc6dfbad9
