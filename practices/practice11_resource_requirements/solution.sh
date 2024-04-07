# A pod called rabbit is deployed. Identify the CPU requirements set on the Pod
kubectl describe pods rabbit # found requests cpu is 1

# Another pod called elephant has been deployed in the default namespace. 
# It fails to get to a running state. Inspect this pod and identify the Reason why it is not running.
kubectl describe pods elephant # in events section: 
#     State:          Waiting
#      Reason:       CrashLoopBackOff
#    Last State:     Terminated
#      Reason:       OOMKilled <- this is the actual reason it goes to waiting state

# The status OOMKilled indicates that it is failing because the pod ran out of memory. Identify the memory limit set on the POD.
kubectl describe pods elephant 
#    Limits:
#      memory:  10Mi
#    Requests:
#      memory:     5Mi

# The elephant pod runs a process that consumes 15Mi of memory. Increase the limit of the elephant pod to 20Mi.
kubectl get pods elephant -o yaml > elephant.yaml
vim elephant.yaml
kubectl delete pods elephant
kubectl create -f elephant.yaml

# make sure new pod is running
kubectl get pods elephant
kubectl top pods # check the resources used by pod

# Delete the elephant Pod.
kubectl delete pods elephant








