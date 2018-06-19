# Shop Microservices Demo 

> Check out my Kubernetes + Spinnaker installation instructions [here](./K8S.MD) and [here](./SPINNAKER.MD)

Goal is to demonstrate microservices and CI/CD with [Spinnaker](https://www.spinnaker.io/) on [Kubernetes](https://kubernetes.io/).
The demo app consists of 3 very simple connected microservices (shopfront, productcatalogue and stockmanager) and a microservice API gateway ([Ambassador](https://blog.getambassador.io/)).
The shopfront accesses productcatalogue and stockmanager (proxy microservice pattern).
The initial code for the demo is stolen [here](https://www.oreilly.com/ideas/how-to-manage-docker-containers-in-kubernetes-with-java) and has been enhanced a bit and tuned for Spinnaker.
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

GitHub (source code + dockerfile) --push-hook-> Travis (build java + docker image) --push docker image--> docker hub --polling-> spinnaker --deploy-> k8s (AWS)

# Ambassador API Gateway

> [Important: Microservice API Gateway <> Enterprise API Gateway](https://www.getambassador.io/about/microservices-api-gateways)

> Many of the typical Spring Cloud components and concerns (Zuul, Hystrix, Eureka or ServiceDiscovery in general, etc) were made for non-kubernetes setups. You will find that, in Kubernetes generally, and in Ambassador explicitly, a lot of these functionalities are implicitly or explicitly taken care of.

The shopfront will be accessible on a URI exposed by [Ambassador](https://blog.getambassador.io/).
Ambassador is a distribution of [Envoy API Gateway](https://www.envoyproxy.io/docs/envoy/latest/intro/what_is_envoy) specifically designed for Kubernetes.
Ambassador operates as a specialized control plane to expose Envoy’s functionality as Kubernetes *annotations*, which assures seamless integration and ease-of-use.
The API gateway offers a [plethora of features](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/arch_overview) that are very interesting in a Microservice context, but there is quite some overlap with other (standard) components that we have (Consul, Hystrix etc).
Some time will be needed to investigate what to use when, and how things fit in eachother. For example:
* (how) will we combine the multi-datacenter servicediscovery of HashiCorp Consul, with the (internal) service discovery of Ambassador ? does it even make sense to use Consul for service discovery, or will we simply use it as a config server ?
* Will we use Hystrix, or the circuit breaker offered by Ambassador ? 
* How does the health checking of Envoy/Ambassador can be linked to the Spring Boot Actuator health checks ?
* etc

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

------- POD 1 --------------------    ------- POD 2 ----------------------
                                 |   |   Consul server 0 (Leader)         |
                                 |    ------------------------------------
                                 |    --------- POD 3 --------------------  
Spring Boot App -> Consul Agent  | ->|   Consul server 1                  |
(container 1)      (container 2) |    ------------------------------------
                                 |    -------- POD 4 ---------------------       
                                 |   |   Consul server 2                  |
----------------------------------    ------------------------------------

[Setup with Spring Boot & Docker](https://hariinfo.github.io/notes/Spring-Consul-Kubernetes)

### Create

kubectl create -f consul-config.yaml
kubectl create -f consul-server-service.yaml
kubectl create -f consul-server-deploy.yaml


### Delete

kubectl delete statefulset,service consul
kubectl delete configmap consul-config


[More secure setup of Consul cluster with TLS enabled](https://github.com/kelseyhightower/consul-on-kubernetes)