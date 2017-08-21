GCLOUD_PROJECT:=$(shell gcloud config list project --format="value(core.project)")

all: deploy

TAG = 1.0
PREFIX = bprashanth/nginxhttps
KEY = /tmp/nginx.key
CERT = /tmp/nginx.crt
SECRET = /tmp/secret.json

create-cluster:
	gcloud container clusters create ispa --zone us-central1-a

create-bucket:
	gsutil mb gs://$(GCLOUD_PROJECT)
    gsutil defacl set public-read gs://$(GCLOUD_PROJECT)

build:
	docker build -t gcr.io/$(GCLOUD_PROJECT)/ispa .

push: build
	gcloud docker push gcr.io/$(GCLOUD_PROJECT)/ispa

template:
	sed -i ".tmpl" "s/\$$GCLOUD_PROJECT/$(GCLOUD_PROJECT)/g" ispa.yaml

deploy: push template
	kubectl create -f alltogether.yaml

update:
	kubectl rolling-update ispa --image=gcr.io/${GCLOUD_PROJECT}/ispa

delete:
	kubectl delete rc ispa
	kubectl delete service ispa
