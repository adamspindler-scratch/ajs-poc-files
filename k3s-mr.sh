#!/bin/bash
set -euxo pipefail
# Wait for the Instruqt host bootstrap to finish
until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]
do
    sleep 1
done

# download the multi region crdb.yaml file
curl https://raw.githubusercontent.com/adamspindler/crdb-public-demo/refs/heads/main/crdb-mr.yaml --output /var/lib/rancher/k3s/server/manifests/crdb.yaml

# Enable and start k3s service
systemctl enable k3s
systemctl daemon-reload
systemctl start k3s

# Waiting for cockroachdb-emea-0 to be phase=Running...
while true; do
  # If it disappears (e.g., being rescheduled), wait for it again.
  if ! kubectl get pod cockroachdb-emea-0 >/dev/null 2>&1; then
    until kubectl get pod cockroachdb-emea-0 >/dev/null 2>&1; do
      sleep 1
    done
  fi

  phase="$(kubectl get pod cockroachdb-emea-0 -o jsonpath='{.status.phase}' 2>/dev/null || echo "")"
  if [[ "${phase}" == "Running" ]]; then
    break
  fi
  sleep 1
done

# Initialise the cluster
kubectl exec cockroachdb-emea-0 -- /cockroach/cockroach init --insecure --host=localhost:26257

# alter the script to provide SQL access to use the correct pod name:
sed -i 's/cockroachdb-0/cockroachdb-emea-0/' /root/cockroach/sql.sh  
