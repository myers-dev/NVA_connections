# NVA_connections

# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput#network-flow-limits



# VMs that belongs to VNET can handle 500k active connections for all VM sizes with 500k active flows in each direction.

# https://github.com/wg/wrk?ref=thechiefio

https://www.digitalocean.com/community/tutorials/how-to-benchmark-http-latency-with-wrk-on-ubuntu-14-04

git clone https://github.com/wg/wrk
cd wrk/src

az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights
az aks install-cli


rg=`terraform output rg | tr -d "\""`

subnet1=`terraform output subnet1_id | tr -d "\""`
subnet2=`terraform output subnet2_id | tr -d "\""`





sudo docker ps
sudo docker exec -it brave_kepler bash

sudo usermod -aG docker andrew

sudo usermod -aG docker andrew

az acr create -g $rg -n acrcopernic --sku Basic --admin-enabled
az acr login --name acrcopernic


docker build --network=host -t andrew/wrk .
docker tag andrew/wrk acrcopernic.azurecr.io/wrk
docker push acrcopernic.azurecr.io/wrk

# Create
# ----------aks 1


az aks create --resource-group "${rg}" --name aks1 --node-count 16 --enable-addons monitoring \
--generate-ssh-keys --vnet-subnet-id "${subnet1}" --service-cidr 172.16.0.0/24 --dns-service-ip 172.16.0.10 \
--network-plugin azure --attach-acr acrcopernic --enable-cluster-autoscaler --min-count 1 --max-count 100

az aks update --resource-group "${rg}" --name aks1 --enable-cluster-autoscaler --min-count 1 --max-count 100

az aks get-credentials --name aks1 --resource-group $rg

kubectl config get-contexts
kubectl config use-context aks1


kubectl create deployment wrk --image=acrcopernic.azurecr.io/wrk:latest --replicas=20 -- bash -c "while true; do  wrk -t12 -c1200 -d3000s http://10.1.0.253:80 ; done "
kubectl scale --replicas=240 deployment/wrk


#-----------aks2--------------------

az aks create --resource-group "${rg}" --name aks2 --node-count 3 --enable-addons monitoring \
--generate-ssh-keys --vnet-subnet-id "${subnet2}" --service-cidr 172.16.0.0/24 --dns-service-ip 172.16.0.10 \
--network-plugin azure --attach-acr acrcopernic --enable-cluster-autoscaler --min-count 1 --max-count 100

az aks update --resource-group "${rg}" --name aks2 --enable-cluster-autoscaler --min-count 1 --max-count 100

az aks get-credentials --name aks2 --resource-group $rg 



kubectl config get-contexts
kubectl config use-context aks2

kubectl create deployment nginx --image=nginx
kubectl scale --replicas=80 deployment/nginx

kubectl apply -f aks2-lb.yaml 

----------------------

https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli



https://github.com/wg/wrk
wrk -t12 -c400 -d30s  http://10.2.0.4:80

root@wrk:/# wrk -t12 -c400 -d30s http://10.1.0.4:80
Running 30s test @ http://10.1.0.4:80
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    39.60ms   36.48ms 718.47ms   84.94%
    Req/Sec     0.95k   169.39     1.78k    69.22%
  340231 requests in 30.05s, 278.70MB read
Requests/sec:  11322.80
Transfer/sec:      9.28MB

#----------------------------------------

az aks get-credentials --name aks1 --resource-group $rg
az aks get-credentials --name aks2 --resource-group $rg

    


# ----------------------

sysctl -w net.ipv4.ip_forward=1