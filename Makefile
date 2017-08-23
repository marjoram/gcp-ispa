GCLOUD_PROJECT:="ispa-176718"
DOCKER_USER="marjoram0"

create-cluster:
	gcloud container clusters create ispa --zone us-central1-b

delete-cluster:
	gcloud container clusters delete ispa

create-bucket:
	gsutil mb gs://coherent-window-177723
    gsutil defacl set public-read gs://coherent-window-177723

delete:
	kubectl delete -f isba/isba-deployment.yml
	kubectl delete -f isba/isba-services.yml

create:
	kubectl create -f isba/isba-deployment.yml
	kubectl create -f isba/isba-services.yml

refresh: delete
	kubectl create -f isba/isba-deployment.yml
	kubectl create -f isba/isba-services.yml

sqlup:
	gcloud sql instances patch isba-db --activation-policy ALWAYS

sqldown:
	gcloud sql instances patch isba-db --activation-policy NEVER
