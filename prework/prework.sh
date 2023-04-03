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

kubectl label node worker1.rke1.demo.netapp.com "topology.kubernetes.io/region=west" --overwrite
kubectl label node worker2.rke1.demo.netapp.com "topology.kubernetes.io/region=west" --overwrite
kubectl label node worker3.rke1.demo.netapp.com "topology.kubernetes.io/region=east" --overwrite

kubectl label node worker1.rke1.demo.netapp.com "topology.kubernetes.io/zone=west1" --overwrite
kubectl label node worker2.rke1.demo.netapp.com "topology.kubernetes.io/zone=west1" --overwrite
kubectl label node worker3.rke1.demo.netapp.com "topology.kubernetes.io/zone=east1" --overwrite


echo "#######################################################################################################"
echo "Make tridentctl working"
echo "#######################################################################################################"

cd
mkdir 22.10.0 && cd 22.10.0
wget https://github.com/NetApp/trident/releases/download/v22.10.0/trident-installer-22.10.0.tar.gz
tar -xf trident-installer-22.10.0.tar.gz
rm -f /usr/bin/tridentctl
sudo cp trident-installer/tridentctl /usr/bin/

echo
tridentctl -n trident version

echo "#######################################################################################################"
echo "Creating Backends with kubectl"
echo "#######################################################################################################"

cd /home/user/kompaktlivelab23/prework/

kubectl create -n trident -f secret_ontap_nfs-svm_username.yaml
kubectl create -n trident -f secret_ontap_iscsi-svm_chap.yaml
kubectl create -n trident -f backend_nas.yaml
kubectl create -n trident -f backend_san.yaml
