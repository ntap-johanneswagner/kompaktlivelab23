#!/bin/bash


if [[ $(yum info jq -y 2> /dev/null | grep Repo | awk '{ print $3 }') != "installed" ]]; then
    echo "#######################################################################################################"
    echo "Install JQ"
    echo "#######################################################################################################"
    yum install -y jq
fi

echo "#######################################################################################################"
echo "Add Region & Zone labels to Kubernetes nodes"
echo "#######################################################################################################"

kubectl label node rhel1 "topology.kubernetes.io/region=west" --overwrite
kubectl label node rhel2 "topology.kubernetes.io/region=west" --overwrite
kubectl label node rhel3 "topology.kubernetes.io/region=east" --overwrite

kubectl label node rhel1 "topology.kubernetes.io/zone=west1" --overwrite
kubectl label node rhel2 "topology.kubernetes.io/zone=west1" --overwrite
kubectl label node rhel3 "topology.kubernetes.io/zone=east1" --overwrite

if [ $(kubectl get nodes | wc -l) = 5 ]; then
  kubectl label node rhel4 "topology.kubernetes.io/region=east"
  kubectl label node rhel4 "topology.kubernetes.io/zone=east1"
fi      
echo "#######################################################################################################"
echo "Make tridentctl working"
echo "#######################################################################################################"

cd
mkdir 22.10.0 && cd 22.10.0
wget https://github.com/NetApp/trident/releases/download/v22.10.0/trident-installer-22.10.0.tar.gz
tar -xf trident-installer-22.10.0.tar.gz
rm -f /usr/bin/tridentctl
cp trident-installer/tridentctl /usr/bin/

echo "#######################################################################################################"
echo "Install new Trident Operator (22.10.0) with Helm"
echo "#######################################################################################################"


echo "#######################################################################################################"
echo "Check"
echo "#######################################################################################################"

frames="/ | \\ -"
while [ $(kubectl get -n trident pod | grep Running | wc -l) -ne 5 ]; do
    for frame in $frames; do
        sleep 0.5; printf "\rWaiting for Trident to be ready $frame" 
    done
done

echo
tridentctl -n trident version

echo "#######################################################################################################"
echo "Creating Backends with kubectl"
echo "#######################################################################################################"

cd /root/storagews/prework

kubectl create -n trident -f secret_ontap_nfs-svm_username.yaml
kubectl create -n trident -f secret_ontap_iscsi-svm_chap.yaml
kubectl create -n trident -f backend_nas.yaml
kubectl create -n trident -f backend_san.yaml
