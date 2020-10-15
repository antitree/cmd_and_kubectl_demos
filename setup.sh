#!/bin/bash
# This setup script creates a new cluster in GKE

# Keep your history file clean for demos:
#cp ./zsh_history ./.zsh_history
#export HISTFILE=./.zsh_history

# Configure a GKE instance 
PROJECT_NAME="shmoocon-talk-hacking"
REGIONS="us-east1-d"
gcloud beta container \
    `# Project name you've set in gcloud` \
    --project "$PROJECT_NAME" \
    `# cluster name, Arbitrary` \
    clusters create "standard-cluster-1" \
    `# Whatever region you like` \
    --zone "$REGIONS" \
    --no-enable-basic-auth \
    `# This will need to be changed as GKE stop supporting versions. E.g. may need to change to 1.15.8 if point release` \
    --cluster-version "1.15.12-gke.4000" \
    `# Do you care about money?` \
    --machine-type "e2-standard-2" \
    `# ubuntu because it's easier to priv esc in` \
    --image-type "UBUNTU" \
    --disk-type "pd-standard" \
    --disk-size "30" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    `# As of 2/2/2020 this was needed to support PSPs` \
    --enable-kubernetes-alpha \
    --num-nodes "3" \
    --no-enable-stackdriver-kubernetes \
    --no-enable-ip-alias \
    `# You can set this to something you've already made or look up your project` \
    --network "projects/$PROJECT_NAME/global/networks/default" \
    --subnetwork "projects/$PROJECT_NAME/regions/us-east1/subnetworks/default" \
    `# Needed to setup a public service for the webadmin service` \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --no-enable-autoupgrade \
    --no-enable-autorepair \
    --no-shielded-integrity-monitoring \
    `# Needed for the ... pod security policy. If you don't want to do this you don't need an alpha GKE either` \
    --enable-pod-security-policy

## setup local kubeconfig
gcloud container clusters get-credentials standard-cluster-1

## add secure namespace with psp
kubectl apply -f clusterrole_restricted.yaml

## deploy webadmin to secure namespace
kubectl apply -f webadmin.yaml -n secure

## enable load balancer and service in GKE
kubectl apply -f public_webadminsvc.yaml -n secure

## allow the secure/webadmin token to access the default/endpoints api
kubectl apply -f webadmin_allow_role_to_see_endpoints.yaml

## deploy webadmin to insecure namespace
kubectl apply -f webadmin.yaml -n default

## Get the podIP of the default pod you'll need later
# If you want to give youself some help, dump the IP of the other webadmin service so you don't have to nmap it
#echo "This is the PodIP of the webadmin pod in the default namespace: "
#kubectl get deployments webadmin -d default -o yaml | grep podIP

## Get svc endpoint
kubectl get svc -n secure --watch


