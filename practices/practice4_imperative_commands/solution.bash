# tip: leverage `kubectl apply -f` to modify generated YAML and create the object

# Deploy a pod named nginx-pod using the nginx:alpine image.
kubectl run nginx-pod --image=nginx:alpine

# Deploy a redis pod using the redis:alpine image with the labels set to tier=db
kubectl run redis --image=redis:alpine --dry-run=client -o=yaml > redis-deploy-definition.yaml
vi redis-deploy-definition.yaml # modify labels to tier: db
kubectl apply -f redis-deploy-definition.yaml

# Easier solution to above >.>
kubectl run redis --image=redis:alpine --labels="tier=db"

# Create a service redis-service to expose the redis application within the cluster on port 6379.
kubectl expose pod redis --name redis-service --port=6379 --type=ClusterIP

# Create a deployment named webapp using the image kodekloud/webapp-color with 3 replicas.
kubectl create deployment webapp --image=kodekloud/webapp-color --replicas=3

# Create a new pod called custom-nginx using the nginx image and expose it on container port 8080.
kubectl run custom-nginx --image=nginx --port=8080

# Create a new namespace called dev-ns.
kubectl create namespace dev-ns

# Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas.
kubectl create deployment redis-deploy --namespace=dev-ns --image=redis --replicas=2

# Create a pod called httpd using the image httpd:alpine in the default namespace. 
# Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80.
kubectl run httpd --image=httpd:alpine
kubectl expose pod httpd --name httpd --port=80 service/httpd exposed

# easier way
kubectl run httpd --image=httpd:alpine --port=80 --expose=true