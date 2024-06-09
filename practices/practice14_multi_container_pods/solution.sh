# how many container in pods red?
kubectl get pods red

# identify name of containers in blue pod
kubectl describe pods blue # teal and navy

# Create a multi-container pod with 2 containers.
# Use the spec given below:
# If the pod goes into the crashloopbackoff then add the command sleep 1000 in the lemon container.
kubectl run yellow --dry-run=true -o yaml > yellow.yaml
vim yellow.yaml
kubectl create -f yellow.yaml

#We have deployed an application logging stack in the elastic-stack namespace. Inspect it.
#Before proceeding with the next set of questions, please wait for all the pods in the elastic-stack namespace to be ready. This can take a few minutes.

