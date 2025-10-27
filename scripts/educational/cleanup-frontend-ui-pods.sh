#!/bin/bash
# cleanup-frontend-ui-pods.sh
# Force delete stuck frontend-ui pods and restart deployment

set -e

NAMESPACE=${1:-default}
DEPLOYMENT=frontend-ui

# Get stuck pods (Terminating, CrashLoopBackOff, ImagePullBackOff, etc.)
pods=$(kubectl get pods -n "$NAMESPACE" -l app=$DEPLOYMENT --field-selector=status.phase!=Running -o jsonpath='{.items[*].metadata.name}')

if [ -n "$pods" ]; then
  echo "Deleting stuck pods: $pods"
  for pod in $pods; do
    kubectl delete pod "$pod" -n "$NAMESPACE" --grace-period=0 --force || true
  done
else
  echo "No stuck pods found for $DEPLOYMENT."
fi

# Restart deployment to trigger fresh rollout
kubectl rollout restart deployment "$DEPLOYMENT" -n "$NAMESPACE"

echo "Cleanup and restart complete."
