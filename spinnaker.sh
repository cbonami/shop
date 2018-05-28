#!/bin/bash
export DECK_POD=$(kubectl get pods --namespace spinnaker -l "component=deck,app=kubelive-spinnaker" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace spinnaker $DECK_POD 9000

