GCLOUD_PROJECT:=$(shell gcloud config list project --format="value(core.project)")

.PHONY: all
all: deploy

.PHONY: create-cluster
create-cluster:
	gcloud container clusters create ispa --zone us-central1-a

.PHONY: create-bucket
create-bucket:
	gsutil mb gs://$(GCLOUD_PROJECT)
    gsutil defacl set public-read gs://$(GCLOUD_PROJECT)

.PHONY: build
build:
	docker build -t gcr.io/$(GCLOUD_PROJECT)/ispa .

.PHONY: push
push: build
	gcloud docker push gcr.io/$(GCLOUD_PROJECT)/ispa

.PHONY: template
template:
	sed -i ".tmpl" "s/\$$GCLOUD_PROJECT/$(GCLOUD_PROJECT)/g" ispa.yaml

.PHONY: deploy
deploy: push template
	kubectl create -f alltogether.yaml

.PHONY: update
update:
	kubectl rolling-update ispa --image=gcr.io/${GCLOUD_PROJECT}/ispa

.PHONY: delete
delete:
	kubectl delete rc ispa
	kubectl delete service ispa
