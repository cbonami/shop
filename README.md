# Shop Demo

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

## CI/CD pipeline

GitHub (source code + dockerfile) --push-hook-> [Travis](https://travis-ci.org/) (build java + docker image) --push docker image--> docker hub --polling-> spinnaker --deploy-> k8s (AWS)

# Ambassador API Gateway

The shopfront will be accessible on a URI exposed by [Ambassador](https://blog.getambassador.io/).

[Important: Microservice API Gateway is different from Enterprise API Gateway](https://www.getambassador.io/about/microservices-api-gateways)
[Rate Limiting](https://blog.getambassador.io/rate-limiting-for-api-gateways-892310a2da02)

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
Pick the name of a pod, eg 'ambassador-67cf9d9f6b-2gjgv'
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