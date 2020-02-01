#!/bin/zsh
# Helper script that lets you get your environment setup as a stolen pod
# For example, if you're running through the demo, it's cheating to be the cluster-admin per gcloud credentials. this will take in the IP and the service token of a service you exploit and generate a kubeconfig file for you. Then switch contexts. You can do this all your self but this is just faster

echo "Enter token: "
read TOKEN
echo "Enter kubernetes API host:"
read K8S

echo "Creating configuration for https://$K8S"

DECODE=$(pyjwt decode --no-verify $(<<EOF echo "$TOKEN"
EOF
))

echo "With token:"
echo $DECODE

echo "Press any key to continue..."
read continue

rm ./demokubeconfig
touch ./demokubeconfig
export KUBECONFIG=./demokubeconfig
export HISTFILE=./.zsh_history
kubectl config set-credentials mark --token="$TOKEN" 
kubectl config set-cluster pwndserver --insecure-skip-tls-verify=true --server=https://$K8S
kubectl config set-context pwndserver --cluster=pwndserver --user=mark
kubectl config use-context pwndserver 
