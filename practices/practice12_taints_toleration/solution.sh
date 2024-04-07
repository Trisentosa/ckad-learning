# How many nodes exist on the system?
# Including the controlplane node.
kubectl get nodes # 2

# Do any taints exist on node01 node?
kubectl describe nodes node01 | grep Taint # none

# Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule
kubectl taint nodes node01 spary=mortein:NoSchedule
kubectl describe nodes node01 | grep Taint

# Create a new pod with the nginx image and pod name as mosquito.
kubectl run --image nginx mosquito

# what is the state of the pod
kubectl get pods mosquito # pending

# why pending
kubectl describe pods mosquito 
# event message: 
# Warning  FailedScheduling  40s   default-scheduler  0/2 nodes are available: 
# 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 
# 1 node(s) had untolerated taint {spray: mortein}. preemption: 0/2 nodes are available: 
# 2 Preemption is not helpful for scheduling.
# ================================================
# why: pod mosquito can't tolerate spray: mortein

# Create another pod named bee with the nginx image, which has a toleration set to the taint mortein.
kubectl run --image nginx --dry-run=client bee -o yaml > bee.yaml
vim bee.yaml
kubectl create -f bee.yaml

# note: to untainted a node, can do `kubectl taint nodes node01 spary-` <- had a typo earlier

# notice `bee` pod was scheduled on node01 despite the taint
kubectl get pods -o wide

# Do you see any taints on controlplane node?
kubectl describe node controlplane | grep Taint # Taints:             node-role.kubernetes.io/control-plane:NoSchedule

# remove the taint from control plane
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane-

# what is state of mosquito now
kubectl get pods mosquito # running on controlplane

