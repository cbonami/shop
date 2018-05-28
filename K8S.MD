# Kubernetes Installation Guide

## Register a domain for the k8s cluster

Register domain: on AWS itself or via another service, like Namecheap.
https://www.namecheap.com/domains-pricing-register.aspx
=> kubernetes.edonis.clubkubernetes.edonis.club

Make a Hosted Zone in Route53: kubernetes.edonis.club
Take note of Route53 DNS records: eg:

```bash
ns-1695.awsdns-19.co.uk.
ns-426.awsdns-53.com.
ns-1009.awsdns-62.net.
ns-1323.awsdns-37.org.
```

Use these 4 DNS-records in Namecheap to make 4 NS records (name='kubernetes') in your domain (edonis.club).

## Create a S3 bucket for the kops-state

Use AWS dashboard to create S3 bucket for kops-state: s3://kops-state-azerty.
Repo-name needs to be unique, so pick something that doesn't exist yet.

## Install Kops CLI

## Create k8s cluster

### Make keypair

Create a new private/public keypair:
```bash
ssh-keygen -f ~/.ssh/id_rsa
```

The private key will be used to log in to the k8s instances.
Btw, this is your public key:

```bash
cat ~/.ssh/id_rsa.pub
```

### Create cluster

```bash
kops create cluster --name=kubernetes.edonis.club --state=s3://kops-state-azerty --zones=eu-central-1a,eu-central-1b --node-count=3 --node-size=t2.medium --master-size=t2.small --dns-zone=kubernetes.edonis.club
kops update cluster kubernetes.edonis.club --yes
```

convenient: edit ~/.bashrc
add these lines:
```bash
export KOPS_STATE_STORE=s3://kops-state-azerty
export EDITOR=nano
```

### Validate cluster

```bash
kops validate cluster kubernetes.edonis.club
```

### Modify cluster
```bash
kops edit ig nodes --state=s3://kops-state-azerty
kops update cluster kubernetes.edonis.club --yes --state=s3://kops-state-azerty
```

### Delete cluster
```bash
kops delete cluster --name kubernetes.edonis.club --state=s3://kops-state-azerty --yes
```

### Optional: Test the cluster
```bash
kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
kubectl expose deployment hello-minikube --type=NodePort
kubectl get service 
```
--> gives you the port the echo-service is running on (31317)
In AWS dashboard, open port via creation of AWS Security Group of master node.
Then go to Route53 > Hosted Zone (kubernetes.edonis.club)
Discover the api-url: http://api.kubernetes.edonis.club:31317/test
Point your browser to that url.