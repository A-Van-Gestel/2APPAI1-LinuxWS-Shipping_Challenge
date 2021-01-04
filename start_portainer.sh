#!/bin/bash

export POD_NAME=$(kubectl get pods --namespace portainer -l "app.kubernetes.io/name=portainer,app.kubernetes.io/instance=portainer" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:9000 to use your application"
kubectl --namespace portainer port-forward $POD_NAME 9000:9000