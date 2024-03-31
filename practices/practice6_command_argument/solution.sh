# how many pod in the node?
kubectl get pods

# What is the command to run the pod `ubuntu-sleeper`
kubectl describe pods ubuntu-sleeper # command directive: sleep 4800

# Create a pod with the ubuntu image to run a container to sleep for 5000 seconds. Modify the file ubuntu-sleeper-2.yaml
vim ubuntu-sleeper-2.yaml
kubectl create -f ubuntu-sleeper-2.yaml

# Create a pod using the file named ubuntu-sleeper-3.yaml. There is something wrong with it. Try to fix it!
vim ubuntu-sleeper-3.yaml
kubectl create -f ubuntu-sleeper-3.yaml

# Update pod ubuntu-sleeper-3 to sleep for 2000 seconds.
vim ubuntu-sleeper-3.yaml
kubectl delete pods ubuntu-sleeper-3
kubectl create -f ubuntu-sleeper-3.yaml

# Inspect the file Dockerfile given at /root/webapp-color directory. What command is run at container startup?
cat  /root/webapp-color/Dockerfile
# Dockerfile
    # FROM python:3.6-alpine

    # RUN pip install flask

    # COPY . /opt/

    # EXPOSE 8080

    # WORKDIR /opt

    # ENTRYPOINT ["python", "app.py"]
# answer python app.py

# Inspect the file Dockerfile2 given at /root/webapp-color directory. What command is run at container startup?
cat  /root/webapp-color/Dockerfile2
# Dockerfile
    # FROM python:3.6-alpine

    # RUN pip install flask

    # COPY . /opt/

    # EXPOSE 8080

    # WORKDIR /opt

    # ENTRYPOINT ["python", "app.py"]

    # CMD ["--color", "red"]
# answer: python app.py --color red

# Inspect the two files under directory webapp-color-2. What command is run at container startup?
cat /root/webapp-color-2/Dockerfile
# Dockerfile
    # FROM python:3.6-alpine

    # RUN pip install flask

    # COPY . /opt/

    # EXPOSE 8080

    # WORKDIR /opt

    # ENTRYPOINT ["python", "app.py"]

    # CMD ["--color", "red"]
    # cat /root/webapp-color-2/webapp-color-pod.yaml 
# .yaml
    # apiVersion: v1 
    # kind: Pod 
    # metadata:
    #   name: webapp-green
    #   labels:
    #       name: webapp-green 
    # spec:
    #   containers:
    #   - name: simple-webapp
    #     image: kodekloud/webapp-color
    #     command: ["--color","green"]
# answer: --color green

# Inspect the two files under directory webapp-color-3. What command is run at container startup?
cat /root/webapp-color-3/Dockerfile 
    # FROM python:3.6-alpine

    # RUN pip install flask

    # COPY . /opt/

    # EXPOSE 8080

    # WORKDIR /opt

    # ENTRYPOINT ["python", "app.py"]

    # CMD ["--color", "red"]

cat /root/webapp-color-3/webapp-color-pod-2.yaml 
    # apiVersion: v1 
    # kind: Pod 
    # metadata:
    #   name: webapp-green
    #   labels:
    #       name: webapp-green 
    # spec:
    #   containers:
    #   - name: simple-webapp
    #     image: kodekloud/webapp-color
    #     command: ["python", "app.py"]
    #     args: ["--color", "pink"]

# answer: python app.py --color pink

# Create a pod with the given specifications. By default it displays a blue background. Set the given command line arguments to change it to green.
kubectl run webapp-green --image=kodekloud/webapp-color --dry-run=client -o yaml
kubectl run --help # look for command and argument seciton here
kubectl run webapp-green --image=kodekloud/webapp-color -- --color green # if need ocmmand can do --command python app.py --color green
