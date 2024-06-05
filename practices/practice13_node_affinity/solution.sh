# How many labels exists on node node01?
kubectl get node node01 --show-labels # alternatively can also kubectl node describe node01

# What is the value set to the label key beta.kubernetes.io/arch on node01?
# answer amd64

# Apply a label color=blue to node node01
kubectl label nodes node01 color=blue

# Create a new deployment named blue with the nginx image and 3 replicas
kubectl create deployment --image nginx --replicas 3 blue

# Which nodes can the pods for the blue deployment be placed on?
# answer: all since no taints or node affinity

# Set Node Affinity to the deployment to place the pods on node01 only.
kubectl edit deployments.apps blue

# Where the pods are placed now
kubectl get pods -o wide # node 01

# Create a new deployment named red with the nginx image and 2 replicas, and ensure it gets placed on the controlplane node only.
# Use the label key - node-role.kubernetes.io/control-plane - which is already set on the controlplane node.
kubectl create deployment --image nginx --replicas 2 -o yaml red > red.yaml
vim red.yaml
kubectl create -f red.yaml