
#!/bin/bash

echo "Finding pod..."

POD=$(kubectl get pods -n devsecops -l app=chaos-app -o jsonpath="{.items[0].metadata.name}")

echo "Deleting pod $POD"

kubectl delete pod $POD -n devsecops

echo "Waiting for recovery..."

kubectl rollout status deployment/chaos-app -n devsecops
