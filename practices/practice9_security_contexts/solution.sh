# What is the user used to execute the sleep process within the ubuntu-sleeper pod?
kubectl exec -it ubuntu-sleeper -- bin/bash # go inside container
ps -ef # see UID -> root
#or
whoami # get user directly

# Edit the pod ubuntu-sleeper to run the sleep process with user ID 1010.
kubectl get pods ubuntu-sleeper -o yaml > change-user.yaml && vim change-user.yaml
# make following changes
# securityContext: 
#    runAsUser: 1010
kubectl apply -f change-user.yaml

# A Pod definition file named multi-pod.yaml is given. With what user are the processes in the web container started?
cat multi-pod.yaml
# found this -> 1002
# -  image: ubuntu
#    name: web
#     command: ["sleep", "5000"]
#     securityContext:
#      runAsUser: 1002

# what about sidecar container
# found this -> not mentioned -> check pod spec -> runAsUser: 1001
#  -  image: ubuntu
#     name: sidecar
#     command: ["sleep", "5000"]

# Update pod ubuntu-sleeper to run as Root user and with the SYS_TIME capability.
kubectl get pods ubuntu-sleeper -o yaml > run-root.yaml && vim run-root.yaml
# add this at container level
#     securityContext:
#      capabilities:
#        add: ["SYS_TIME"]
