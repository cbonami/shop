# Shop Microservices Demo 

> Check out my Kubernetes + Spinnaker installation instructions in [K8S.MD](./K8S.MD) and [SPINNAKER.MD](./SPINNAKER.MD)

> Motivation behind the 'glue'-technology between our microservices -Ambassador/Envoy as a [sidecar container](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/)- can be found in [AMBASSADOR.MD](./AMBASSADOR.MD)

Goal is to demonstrate microservices and CI/CD with [Spinnaker](https://www.spinnaker.io/) on [Kubernetes](https://kubernetes.io/).
The demo app consists of:
* 3 very simple connected microservices ([shopfront](https://github.com/cbonami/shopfront), [productcatalogue](https://github.com/cbonami/productcatalogue) and [stockmanager](https://github.com/cbonami/stockmanager)) 
* and a microservice API gateway ([Ambassador](https://blog.getambassador.io/))

The shopfront accesses productcatalogue and stockmanager (proxy microservice pattern).
The initial code for the demo is stolen [here](https://www.oreilly.com/ideas/how-to-manage-docker-containers-in-kubernetes-with-java) and has been enhanced and slightly tuned for Spinnaker.
Shopfront and stockmanager are based on Spring Boot and Spring Cloud, the productcatalogue is a [Dropwizard](https://www.dropwizard.io/1.3.2/docs/#) service.

To deploy the application in your local docker host, execute the following:
```bash 
docker-compose up
```
Then point your browser to [http://localhost:8010/shopfront](http://localhost:8010/shopfront).

> Note: on Windows/OSX you might want to replace 'localhost' with the IP of your Docker host

However, the purpose of this demo is to demonstrate deployment of these apps on Kubernetes via Spinnaker.
Also, in the k8s deployment, we will make use of [Ambassador](https://blog.getambassador.io/), the Kubernetes-native microservice API-gateway of our choice.
In [this](./K8S.MD) and [this](./SPINNAKER.MD) included guide, there are detailed instructions on how to get a K8S cluster up & running on AWS, and installing Spinnaker on it.

# Prerequisites
 
* [Install Kubernetes Cluster](./K8S.MD)
* [Install Spinnaker](./SPINNAKER.MD)
* Get GitHub account
* Get [Travis](https://travis-ci.org/) account, linked to GitHub account
* Get DockerHub account

## CI/CD pipeline

```bash 
GitHub (source code + dockerfile) --push-hook-> Travis (build java + docker image) --push docker image--> docker hub --polling-> spinnaker --deploy-> k8s (AWS)
```

## Deployment of Ambassador

> For the time being, we deploy Ambassador 'manually' via kubectl, and not (yet) via Spinnaker.

```bash
kubectl apply -f ambassador-service.yaml
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml 
kubectl get svc
```
Then list all pods:
```bash 
kubectl get pods
```
Pick the name of an ambassador-pod, eg 'ambassador-67cf9d9f6b-2gjgv'
On your local machine, use port-forwarding to access Ambassador UI or shopfront.
* Ambassador UI
```bash
kubectl port-forward ambassador-67cf9d9f6b-2gjgv 8877:8877
http://localhost:8877/ambassador/v0/diag/
``` 
* Shopfront
```bash
kubectl port-forward ambassador-67cf9d9f6b-2gjgv 8080:80
http://localhost:8080/shopfront/
``` 

As the shopfront is exposed by the ambassador api gateway, you need to port-forward the ambassador-pod's port (80) to get access to the shopfront.

# Consul 

### Deployment Architecture

```bash 
------- POD 1 --------------------    ------- POD 2 ----------------------
                                 |   |   Consul server 0 (Leader)         |
                                 |    ------------------------------------
                                 |    --------- POD 3 --------------------  
Spring Boot App -> Consul Agent  | ->|   Consul server 1                  |
(container 1)      (container 2) |    ------------------------------------
                                 |    -------- POD 4 ---------------------       
                                 |   |   Consul server 2                  |
----------------------------------    ------------------------------------
```

[Setup with Spring Boot & Docker](https://hariinfo.github.io/notes/Spring-Consul-Kubernetes)

### Create

```bash 
kubectl create -f consul-config.yaml
kubectl create -f consul-server-service.yaml
kubectl create -f consul-server-deploy.yaml
```


### Delete

```bash 
kubectl delete statefulset,service consul
kubectl delete configmap consul-config
```


[More secure setup of Consul cluster with TLS enabled](https://github.com/kelseyhightower/consul-on-kubernetes)