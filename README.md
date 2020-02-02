# Command and KubeCTL
Setup and instructions for Command and Kubectl presentation. 

Slides: https://docs.google.com/presentation/d/1y6KGGT5Uw27cCgFMKiGv0NjRhq8YvjY_S9UG8s_TThg/edit?usp=sharing

## Background: 

This is a demo used during the Command and KubeCTL talk that builds and
environment representing many of the common flaws I've seen doing numerous
assessments and hearing stories in the industry. 

The presentation describes a fake company named "eKlowd" that has configured a
multi-tenant kubernetes cluster that allows different development groups to
deploy a cluster into the their own namespace. 

So this demo setups up 2 namespaces with various restrictions applied to them
including:

* Role / RoleBindings applied to the namespace
* A PSP that restricts how a Pod can be deployed
* A configuration that allows third party images to be deployed

## Setup
1. Configure gcloud on your environment and login
1. Enable GKE support for your account
1. Clone down this repo
1. Modify the yaml file replacing refrences to
   `gcr.io/shmoocon-talk-hacking/brick` and
   `gcr.io/shmoocon-talk-hacking/webadmin` to wherever you want to store copies
   of these images. (See the build instructions in the README under /images in
   this repo)
1. Run ./setup.sh 

*NOTE: As of 2/2/2020, this will create a GKE instance with a specific version.
You may need to change the region and the version. Look at the `gcloud` command
in the `setup.sh` script.*

Wait for the LB to provide you with a public IP for the Webadmin service. 

## Demo

If you haven't seen the demo and you want to figure it out yourself, first you
should start out by finding the public IP of the Webadmin service and start at: 

~~~
https://<LB IP For Webadmin>:5000/
~~~

This application has RCE as so:

~~~
https://<LB IP>:5000/?cmd=ls
~~~

You can execute any command you want within the context of the container. Use
this to try and pivot through the cluster and take it over. 
