# how many namespace in the node
kubectl get namespace 

# get pods from dev research
kubectl get pods --namespace=research
kubectl get pods -n=research

# create redis pod in finance namespace
kubectl run redis --image=redis --namespace=finance

# which namespace has the blue pod in it
kubectl get pods --all-namespaces | grep blue

# what DNS name should Blue (marketing namespace) use to access its own service: db-service
# Answer: db-service
kubectl get svc -n=marketing # get by services

# what DNS name should Blue (marketing namespace) use to access other service: db-service (in dev namespace)
# Answer: dev.db-service
db-service.dev.svc.cluster.local

