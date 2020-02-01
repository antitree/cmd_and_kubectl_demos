# Images

This folder has 2 images:
1. botty: This is a gotty image preconfigured with a bunch of my favorite tools. I've been tagging it "brick" because it's a blunt object. 
2. pwn_python: This is a flask application that executes any command you provide in the "cmd" url param. 

Build either of these and push them to a repo of your choice like:

~~~bash
docker build . -t gcr.io/<PROJECT_NAME>/brick
docker push gcr.io/<PROJECT_NAME>/brick
~~~

Once you've tagged them and pushed them to a repo of your choosing, update the other YAML in the cluster deployment. 
