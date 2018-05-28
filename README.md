# Ambassador API Gateway

[Important: Microservice API Gateway is different from Enterprise API Gateway](https://www.getambassador.io/about/microservices-api-gateways)
[Rate Limiting](https://blog.getambassador.io/rate-limiting-for-api-gateways-892310a2da02)

## Deployment of Ambassador
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