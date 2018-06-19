# Kubernetes Installation Guide

We will make use of [Kops](https://github.com/kubernetes/kops) to create a K8s cluster on AWS.
The cluster will be assigned to a domain name on the internet (eg 'kubernetes.edonis.club').
All setup will be orchestrated from withing a local Ubuntu-based VM.

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

## Install Vagrant on your local host

> todo

## Start a VM

```bash
mkdir ubuntu 
cd ubuntu
vagrant init ubuntu/xenial64
vagrant plugin install vagrant-vbguest
vagrant up
```

Log in into the VM:

```bash
vagrant ssh
```

Do some initialization:

```bash
sudo apt-get update && sudo apt-get -y upgrade
sudo usermod -G vboxsf -a vagrant
```

Maybe best reboot the VM after this, to get the shared folder mounted. On your host OS:

```bash
vagrant reload
vagrant ssh
```

From this moment on, we will be working in the VM.

## Prepare the VM

### SSH keypair

Copy your existing ssh keypair files (id_rsa and id_rsa.pub) to ~/.ssh/ .
I have provided this keypair to you, so that you can access the kubernetes cluster that is running in EA's R&D environment on AWS.

If you are setting up a new cluster, and don't have an existing keypair (in ~/.ssh), then generate a new private/public keypair like this:

```bash
ssh-keygen -f ~/.ssh/id_rsa
```

The private key will be used to log in to the k8s instances.

### Install Python PIP

```bash
sudo apt-get install python-pip
```

### Install AWS CLI

```bash
export LC_ALL=C
pip install awscli --upgrade --user
```

Configure AWS CLI:

```bash
aws configure

AWS Access Key ID [****************TIOA]: 
AWS Secret Access Key [****************/yfq]: 
Default region name [eu-central-1]: 
Default output format [json]:
```

Use the credentials for the TME R&D AWS account, if you are connecting to the existing cluster that I've set up there.

### Install kubectl

```bash
sudo snap install kubectl --classic
```

*Important* : If you received a kubectl _config_ file (pointing to an existing kubernetes cluster on AWS), you should copy it to ~/.kube/. Then you can check if you can connect to the cluster:

```bash
kubectl get nodes
```

### Install Kops

```bash
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
```

### Install Helm

```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

## Create Kubernetes cluster

### Create cluster

```bash
kops create cluster --name=kubernetes.edonis.club --state=s3://kops-state-azerty --zones=eu-central-1a,eu-central-1b --node-count=3 --node-size=t2.medium --master-size=t2.small --dns-zone=kubernetes.edonis.club
kops update cluster kubernetes.edonis.club --yes
```

Optional but convenient: edit ~/.bashrc
Add these lines:
```bash
# avoids having to specify this every time your run the kops CLI
export KOPS_STATE_STORE=s3://kops-state-azerty

# only if you don't like vi
export EDITOR=nano
```

### Validate cluster

```bash
kops validate cluster kubernetes.edonis.club
```

### Modify cluster

You can add nodes to the cluster, change type of nodes, etc by editing the kops-state.

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
--> gives you the port the echo-service is running on (31317).

In AWS dashboard, open port via creation of AWS Security Group of master node.
Then go to Route53 > Hosted Zone (kubernetes.edonis.club).
Discover the api-url: http://api.kubernetes.edonis.club:31317/test .
Point your browser to that url.