# How many pods in the system
kubectl get pods #0

# How many ReplicaSets exist on the system?
kubectl get replicasets # fail first, 0

# How about now?
kubectl get replicasets # 1 -> new-replica-set   4         4         0       21s

# What image is used for these containers
kubectl describe replicaset <replicaset-name>

# 0 Pods ready why?
# Image doesn't exist

# Delete any of the pods
kubectl delete pod <pod-name>

# There are still 4 pods, because of replicasets replica's field

# fix replicaset-definiton-1.yaml
kubectl explain replicaset #  get information on objects expected fields and definitions
kubectl create -f replicaset-definition-1.yaml # to check first the error message
vim replicaset-definition-1.yaml # fix `v1` to `apps/v1`

# fix replicaset-definition-2.yaml
vim replicaset-definition-2.yaml
kubectl create -f replicaset-definition-2.yaml # to check first the error message
vim replicaset-definition-2.yaml # fix selector `matchLabels` have to match

# delete pods replicaset-1 and replicaset-2
kubectl delete replicaset replicaset-1 replicaset-2

# edit new-replica-set to use busybox image instead of busybox777
kubectl edit rs new-replica-set # btw rs simplification fo replicaset
kubectl delete pod new-replica-set-1 new-replica-set-2 new-replica-set-3 new-replica-set-4 # delete so new rs recreate

# use scale command to new-replica-set to scale up to 5 pod
kubectl scale --replicas=5 replicaset new-replica-set

# use scale command to new-replica-set to scale down to 2 pod
kubectl scale --replicas=2 replicaset new-replica-set