#!/bin/bash
set -euxo pipefail
# Wait for the Instruqt host bootstrap to finish
until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]
do
    sleep 1
done

# download the application-default.yml file that matched the k8s cluster deployment regions
curl https://raw.githubusercontent.com/adamspindler/crdb-public-demo/refs/heads/main/ledger-application-default.yml --output /root/ledger/config/application-default.yml

# Point the app to the k3s databases:
sed -i 's/localhost:26257/crdb-k3s:26257/' /root/ledger/config/application-default.yml 
