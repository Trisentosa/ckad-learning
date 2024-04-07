# How many Service Accounts exist in the default namespace?
kubectl get serviceaccounts

# What is the secret token used by the default service account?
kubectl describe serviceaccounts default # Tokens: <none>

# We just deployed the Dashboard application. Inspect the deployment. What is the image used by the deployment?
kubectl get deployments.apps # found web-dashboard
kubectl describe deployments.apps web-dashboard #  Image: gcr.io/kodekloud/customimage/my-kubernetes-dashboard

# What is the state of the dashboard? Have the pod details loaded successfully?
kubectl get pods # all web-dashboard pod are running
# check the dahsboard(seem some error related to the serviceaccount permission, not allowing to show pod detail)

# What type of account does the Dashboard application use to query the Kubernetes API? (and which account used)
kubectl describe pods web-dashboard-74cbcd9494-w2nmv # Service Account: default (it uses service account)

# At what location is the ServiceAccount credentials available within the pod?
kubectl describe pods web-dashboard-74cbcd9494-w2nmv # check mounts directive
kubectl exec -it web-dashboard-74cbcd9494-w2nmv -- cat /var/run/secrets/kubernetes.io/serviceaccount/token # /var/run/secrets

# The application needs a ServiceAccount with the Right permissions to be created to authenticate to Kubernetes. The default ServiceAccount has limited access. Create a new ServiceAccount named dashboard-sa.
kubectl create serviceaccount dashboard-sa

# We just added additional permissions for the newly created dashboard-sa account using RBAC. If you are interested checkout the files used to configure RBAC at /var/rbac. We will discuss RBAC in a separate section.
cat /var/rbac/dashboard-sa-role-binding.yaml

# Enter the access token in the UI of the dashboard application. Click Load Dashboard button to load Dashboard
# Create an authorization token for the newly created service account, copy the generated token and paste it into the token field of the UI.
# To do this, run kubectl create token dashboard-sa for the dashboard-sa service account, copy the token and paste it in the UI.
kubectl describe serviceaccounts dashboard-sa # no tokens yet
kubectl create token dashboard-sa

# You shouldn't have to copy and paste the token each time. 
# The Dashboard application is programmed to read token from the secret mount location. 
# However currently, the default service account is mounted. Update the deployment to use the newly created ServiceAccount
kubectl get deployments.apps web-dashboard -o yaml > deployment.yaml # add serviceAccountName
vim deployment.yaml
kubectl apply -f deployment.yaml
