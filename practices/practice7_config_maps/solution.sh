# How many pods exist in the system (in current default namespace)
kubectl get pods

# What is the environment variable name set on the container in the pod?
kubectl describe pods webapp-color # in Environment, have APP_COLOR: pink

# Update the environment variable on the POD to display a green background.
kubectl get pod webapp-color -o yaml > pod.yaml
vim pod.yaml # change environment section
kubectl delete pods webapp-color
kubectl create -f ppod.yaml

# How many ConfigMaps exists in the default namespace?
kubectl get configmaps

# Identify the database host from the config map db-config.
kubectl describe configmaps db-config # value: SQL01.example.com

# Create a new ConfigMap for the webapp-color POD. Use the spec given below.
vim configmap.yaml
kubectl create -f configmap.yaml

# Update the environment variable on the POD to use only the APP_COLOR key from the newly created ConfigMap.
kubectl get pod webapp-color -o yaml > pod2.yaml
vim pod2.yaml
# make this change
#   containers:
#   - env:
#     - name: APP_COLOR
#       valueFrom: 
#         configMapKeyRef: 
#           name: webapp-config-map
#           key: APP_COLOR
kubectl delete pods webapp-color
kubectl create -f ppod.yaml
