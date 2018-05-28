# Spinnaker Installation Guide

## Install kubectl

### Ubuntu

Easiest is to use snap, which is installed by default on Ubuntu >=16.04:

```bash
sudo snap install kubectl --classic
```

### OSX

```bash
brew install kubectl
```

### Windows

```bash
choco install kubernetes-cli
```

[More options](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Install Helm

### Ubuntu

```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

### Windows

[Details here](https://medium.com/@JockDaRock/take-the-helm-with-kubernetes-on-windows-c2cd4373104b)

## Config RBAC : 'tiller' service account

Note: tiller is the backend service of Helm

```bash
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
```
in case service account 'tiller' is not used: then default service account is used: this means:

```bash
kubectl create clusterrolebinding admin-clusterrolebinding --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

Also see 
* [Similar instructions for K8s on GCloud](https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine#configure_spinnaker)
* [Kubernetes RBAC](http://docs.heptio.com/content/tutorials/rbac.html)

## Install helm/tiller on k8s cluster

```bash
helm init --service-account tiller
```
(or just 'helm init' if sa tiller is not used)
general info: https://dzone.com/articles/securing-helm

sidenote: remove tiller
option1: helm reset -f
option2: kubectl -n "kube-system" delete deployment tiller-deploy
tiller in its own namespace? https://medium.com/@amimahloof/how-to-setup-helm-and-tiller-with-rbac-and-namespaces-34bf27f7d3c3

## Install spinnaker with helm
https://thenewstack.io/getting-started-spinnaker-kubernetes/
helm chart can be found here: https://github.com/kubernetes/charts/tree/master/stable/spinnaker
```bash
curl -Lo values.yaml https://raw.githubusercontent.com/kubernetes/charts/master/stable/spinnaker/values.yaml
```
Make changes to spinnaker.yml: add docker hub repo's.
Then do ythe actual installation of spinnaker:

```bash
helm install -n kubelive stable/spinnaker -f values.yaml --timeout 300 --namespace spinnaker
```
check if all ok: 
```bash
kubectl get pods --namespace spinnaker
```
## Use spinnaker

You want to be able to go to spinnaker dashboard from your _local_ host's browser.
The 'kubectl port-forward' when executed from the Ubunbtu VM will only bind to the local (=VM's) IP and _not_ to your host's IP.
Do port-forwarding workaround: copy ~/.kube/config from your VM to your host system (where kubectl is also installed)
Check if works: on host: 
```bash
kubectl get node
```
This should list all pods in the k8s cluster on AWS.

Then on host: forward the port 9000:
```bash
export DECK_POD=$(kubectl get pods --namespace spinnaker -l "component=deck,app=kubelive-spinnaker" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $DECK_POD 9000
```
Point browser to: http://localhost:9000
This should show the spinnaker dashboard.

Work around bug/problem: https://github.com/kubernetes/charts/issues/5483
-> list of applications, namespaces in spinnaker is empty :(
If you check the k8s logs:

```bash
kubectl logs -n spinnaker kubelive-spinnaker-clouddriver-d4959567-kctkg -f
```
-> com.netflix.spinnaker.clouddriver.kubernetes.v1.deploy.exception.KubernetesOperationException: Get Namespaces for account local failed: Forbidden! Configured service account doesn't have access. Service account may have been revoked. namespaces is forbidden: User "system:serviceaccount:spinnaker:default" cannot list namespaces at the cluster scope

Insecure workaround: 

```bash
kubectl create clusterrolebinding spinnaker-default-crbinding --clusterrole cluster-admin --serviceaccount=spinnaker:default
```

## Upgrade spinnaker config (values.yaml)

Edit values.yml, then

```bash
helm upgrade -f values.yaml kubelive stable/spinnaker
```

## Remove spinnaker

```bash
helm del --purge kubelive
```

## Create namespaces 'DEV' and 'PROD'

https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/

```bash
kubectl create -f https://k8s.io/docs/tasks/administer-cluster/namespace-dev.json
kubectl create -f https://k8s.io/docs/tasks/administer-cluster/namespace-prod.json
```

Best-practice: set contexts

Problem: these namespaces don't show up in Spinnaker -- why ??
