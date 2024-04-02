# How many Secrets exist on the system?
kubectl get secrets

# How many secrets are defined in the dashboard-token secret?
kubectl describe secrets dashboard-token # 3 secret: ca.crt, namespace, token

# What is the type of the dashboard-token secret?
# same, can be seen in describe: `Type: kubernetes.io/service-account-token`

# Create a new secret named db-secret with the data given below.
kubectl create secret generic db-secret --dry-run=client -o yaml > secret.yaml
vim secret.yaml

# Configure webapp-pod to load environment variables from the newly created secret
kubectl get pods webapp-pod -o yaml > pod.yaml && vim pod.yaml
#change to this: envFrom property
# spec:
#   containers:
#   - image: kodekloud/simple-webapp-mysql
#     imagePullPolicy: Always
#     name: webapp
#     envFrom:
#       - secretRef:
#           name: db-secret
kubectl delete pods webapp-pod
kubectl create -f pod.yaml
