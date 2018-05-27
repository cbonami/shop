# Ambassador API Gateway

```bash
kubectl apply -f ambassador-service.yaml
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml 
kubectl get svc
kubectl get pods
```
-> pick the name of a pod, eg 'ambassador-67cf9d9f6b-2gjgv'
Use port-forwarding to access
* Ambassador UI:
```bash
kubectl port-forward ambassador-67cf9d9f6b-2gjgv 8877:8877
http://localhost:8877/ambassador/v0/diag/
``` 
* Shopfront:
```bash
kubectl port-forward ambassador-67cf9d9f6b-kpxzt 8080:80
http://localhost:8080/shopfront/
``` 