<div align="center">
  <h1>Kubernetes Certified Application Developer (CKAD) </h1>
</div>

<h1>Table of Contents</h1>

- [Course](#course)
- [Certifications](#certifications)
- [Handbook](#handbook)
  - [Core Concepts](#core-concepts)
    - [Recap - Kubernetes Architecture](#recap---kubernetes-architecture)
    - [`Docker` vs `ContainerD`](#docker-vs-containerd)
    - [Recap - Pods](#recap---pods)
    - [Recaps - Pods with YAML](#recaps---pods-with-yaml)
    - [Practice Test \& Solution - Pods](#practice-test--solution---pods)
    - [Edit Pods (for practial quizzes)](#edit-pods-for-practial-quizzes)
    - [Recap - ReplicaSets, Controllers](#recap---replicasets-controllers)
    - [Practice Test \& Solution - ReplicaSets](#practice-test--solution---replicasets)
    - [Recap: Deployments](#recap-deployments)
    - [Certification Tip: Formatting Output with kubectl](#certification-tip-formatting-output-with-kubectl)
    - [Recap: Namespaces](#recap-namespaces)
    - [Practice Test \& Solution - Namespace](#practice-test--solution---namespace)
    - [Certification Tip: Imperative commands](#certification-tip-imperative-commands)
    - [Practice Test \& Solution - Imperative Commands](#practice-test--solution---imperative-commands)
  - [Configuration](#configuration)
    - [Define, build, and modify contianer images](#define-build-and-modify-contianer-images)
    - [Practice Test \& Solution: Docker Images](#practice-test--solution-docker-images)
    - [Commands and Arguments in Doccker](#commands-and-arguments-in-doccker)
    - [Commands and Arguments in Kubernetes](#commands-and-arguments-in-kubernetes)
    - [Practice Test \& Solution: Commands and Arguments](#practice-test--solution-commands-and-arguments)
    - [Environment Variables](#environment-variables)
    - [ConfigMaps](#configmaps)
    - [Practice Test \& Solution: ConfigMaps](#practice-test--solution-configmaps)
    - [Kubernetes Secrets](#kubernetes-secrets)
    - [Secret Store CSI Driver](#secret-store-csi-driver)
    - [Practice Test \& Solution: Secrets](#practice-test--solution-secrets)
    - [Demo: Encrypting Secret Data at Rest](#demo-encrypting-secret-data-at-rest)
    - [Docker Security](#docker-security)
    - [Security Contexts](#security-contexts)
    - [Practice Test - Security Contexts](#practice-test---security-contexts)
    - [Service Accounts](#service-accounts)
    - [Practice - Service Accounts](#practice---service-accounts)
    - [Resource Requirements](#resource-requirements)
    - [Practice Test - Resource Requirements](#practice-test---resource-requirements)
    - [Taints and Tolerations](#taints-and-tolerations)
    - [Practice Test - Taints and Toleration](#practice-test---taints-and-toleration)
    - [Node Selectors](#node-selectors)


# Course 
https://www.udemy.com/course/certified-kubernetes-application-developer/

# Certifications

- CKAD: https://www.cncf.io/training/certification/ckad/
- Candidate Handbook: https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2
- Exam Tips: https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad

# Handbook

## Core Concepts

### Recap - Kubernetes Architecture

- Nodes(Minions): physical or virtual machine in which kubernetes is installed 
- To maintain availability, we need multiple nodes. 
- Cluster: group of nodes
- Master: another node with kube installed in it, watch over nodes in their cluster, responsible for orchestration of containers on the worker nodes
- Components: things that you get when installing kubernetes
  - API server: users interact with API server to interact with kube cluster
  - etcd: key-value store. Stores information between masters and worker nodes in a distributed manner. Implmeenting locks in a cluster to make sure no conflicts between masters
  - kubelet: agent that runs on each node on each cluster. Make sure that container running in the nodes as expected
  - Container Runtime: underlying software that used to run containers (docker, containerd)
  - Controller: responsible for noticing and responding when container or endpoints goes doewn. It will create new containers if it notice
  - Scheduler: distributing works or containers accross multiple nodes
- Master vs Worker nodes
  - Worker Node (minion): has kubelet and where containers are hosted
  - Master: has kube-apiserver, etcd, controller, scheduler
- `kubectl`
  - used to deploy and manage application on k8s cluster
  - Some basics:
    - `kubectl run <service>`: to run an application on the cluster
    - `kubectl cluster-info`: get information of the cluster
    - `kubectl get nodes`: get nodes of the cluster

### `Docker` vs `ContainerD`

- Container Runtime Interface (CRI): originally kube only made for docker, as it grows popularity, it provides interface to allow other container runtime to be orchestrate by kubernetes as long as they adhere to OCI standards. What is OCI>
- Open Container Interface (OCI)
  - `imagespec`: define how an image should be built
  - `runtimespec`: standards on how any container runtime should be developed
- `dockershim`: temporary way of kubernetes to work with docker. Since docker doesn't use CRI (because CRI is created far after docker is created). It is removed in `v1.24`
- `containerd`: container runtime in docker is `runc`. And the daemon that maintain `runc` is called `containerd`. `containerd` is CRI compatible and is its own runtime separate from docker
  - github: https://github.com/containerd
  - docs: https://containerd.io/
  - `ctr`: containerd cli
    - limited set of features
    - not user friendly
    - can do:
      - pull image
      - run container
  - `nerdctl`
    - provides docker like CLI for containerD, examples:
    ```
    nerdctl run --name redis redis:alpine
    nerdctl run --name webserver -p 80:80 -d nginx
    ```
    - supports docker compose
    - supports newest feature in containerd
      - encrypted container images
      - lazy pulling
      - p2p image distribution
      - image signing and verifying
      - namespaces in k8s
  - `crictl`: 
    - CLI for any CRI compatible container runtimes
    - Installed separately
    - Used to inspect and debug container runtimes
      - Not to create containers ideally
    - Works across different runtimes
    - Used for debuggin purposes
    - docker like cli, but aware of pods
    - Examples:
        ```bash
        crictl pull busybox
        crictl images
        crictl ps -a
        crictl logs <container-id>
        crictl pods # unlike docker, aware of pods
        ```

### Recap - Pods
- Assumptions:
  - the applications already published to docker hub, image can be pulled by k8s
  - we have a running k8s cluster, and is working. All services are in running state
- K8s doesn't assign container directly in worker nodes, instead the containers is encapsulated in k8s objects known as pods. 
- Pod is a single instance of an application. is the smallest object you can create in k8s
- Hierarchy: Kubernetes cluster -> Node -> Pod -> Container
- Scaling up application, meaning to increase the number of pods 
- A pod can contain multiple containers. But not the container of the same kind (helper containers + main container)
- The idea of pod is to contain multiple containers that is part of the same app, so that operation such as creation, removal, load balance, network space can be much easily done.
- `kubectl`
  ```bash
  kubectl run nginx --image nginx # deploys a docker container by creating a pod. Image is pulled from docker hub
  kubectl get pods
  ```

### Recaps - Pods with YAML
- YAML in Kubernetes
```yaml
# pod-definition.yml

apiVersion: v1 #available values: v1, apps/v1
kind: Pod # available values: Pod, Service, ReplicaSet, Deployment
metadata: 
  name: myapp-pod
  labels: # can fit anything key-value pair inside labels field as you see fit
    app: myapp
    type: front-end
spec:
  containers:
    - name: nginx-container # with `-` define list of items
      image: nginx
```
- To create: `kubectl create -f pod-definition.yml`
- To view: `kubectl get pods`
- To inspect pod: `kubectl describe pod myapp-pod`

### Practice Test & Solution - Pods
- Practice: https://kodekloud.com/topic/pods-4
- Solution: [practice1_pods](./practices/practice1_pods)

### Edit Pods (for practial quizzes)
- to edit an existing POD:
  - if given a pod definition file, edit that file and use it to create new pod
  - if not given pod defnition file, extract the definition to a file using command:
  ```bash
  kubectl get pod <pod-name> -o yaml > pod-definition.yaml
  ```
  - To modify the properties of the pod, can utilize the:
  ```bash
  kubectl edit pod <pod-name>
  ```
    - Editable properties (official doc as source of truth: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_edit/)
      - spec.containers[*].image
      - spec.initContainers[*].image
      - spec.activeDeadlineSeconds
      - spec.tolerations
      - spec.terminationGracePeriodSeconds

### Recap - ReplicaSets, Controllers
-  Recap Controllers: brain behind kubernetes
  - processes that monitor kubernetes objects and respond accordingly
- Replication controller: one type of the controller, ensures high availibility by allowing run multiple instances of a single pod in a cluster. 
  - If there is a single pod, replication controller helps by creating new pod if that existing one fails
  - Also help in load balancing & scaling as user demand increases. Replication controller can spans accross multiple nodes in a single cluster
  - Two similar terms: Replication Controller (older) and Replica Set (newer). Minor differences in the way it works, but main concept still same
  - Creating Replication Controller:
    - Define yml file
      ```yaml
      apiVersion: v1
      kind: ReplicationController
      metadata:
        name: myapp-rc
        labels: 
          app: myapp
          type: frontend
        spec:
          template: #should be what our pod definiton be, similar to previous exercies (`pod-definition.yaml`)
            metadata: 
              name: myapp-pod
              labels: 
                app: myapp
                type: front-end
            spec:
              containers:
                - name: nginx-container 
                  image: nginx
            replicas: 3
      ```
    - Create from yml file
    ```bash
    kubectl create -f rc-definition.yml
    ```
    - Get replicationcontroller information
    ```bash
    kubectl get replicationcontroller
    kubectl get pods
    ```
  - Now, Creating ReplicaSet (newer):
    - Major difference: `selector` field. 
      - This allows ReplicaSet to manage pods that were not created as part of the replicaset creation.
      - For example: pods created before or after the replicaset creation that matches `matchLabels` can be managed by ReplicaSet
    - Define yml file
      ```yaml
      apiVersion: apps/v1
      kind: ReplicaSet
      metadata:
        name: myapp-replicaset
        labels: 
          app: myapp
          type: frontend
      spec:
        template: #should be what our pod definiton be, similar to previous exercies (`pod-definition.yaml`)
          metadata: 
            name: myapp-pod
            labels: 
              app: myapp
              type: front-end
          spec:
            containers:
              - name: nginx-container 
                image: nginx
        replicas: 3
        selector: 
          matchLabels:
            type: front-end
      ```
    - Create replicaset
    ```bash
    kubectl create -f replicaset-definition.yml
    ```
    - get information
    ```bash
    kubectl get replicaset
    kubectl get pods
    ```
  - Labels and Selectors:
    - filters out pods for replicaset to monitor and manage
  - Scale
    - How to change number of replicas of our  replicaset. 
      1. Change `replicas` field in the `yml` file and:
      ```bash
      kubectl replace -f replicaset-definition.yml
      ```
      2. use `scale` command
      ```bash
      kubectl scale --replicas=6 -f replicaset-definition.yml 
      # or
      kubectl scale --replicas=6 replicaset myapp-replicaset # replicaset: TYPE | myapp-replicaset: NAME
      ```
  - Commands Summary:
    - `create`
    - `get`
    - `delete`
    - `replace`
    - `scale`

### Practice Test & Solution - ReplicaSets
- Practice: https://uklabs.kodekloud.com/topic/replicasets-2/
- Solution: [practice2_replicasets](./practices/practice2_replicasets/)

### Recap: Deployments
- From `ReplicaSet`, we understand this hierarchy flow: ReplicaSet -> Pods -> Container
- `Deployment` stands here in the hierarchy: Deployment -> ReplicaSet -> Pods -> Container
- It is a kubernetes object that provides ability to upgrade the underlying instance seamlessly, allow to
  - Rolling updates
  - Rollback deployment
  - Pause changes
  - Resume changes
- To create
  - Definition file
      ```yaml
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: myapp-deployment
        labels: 
          app: myapp
          type: frontend
      spec:
        template: #should be what our pod definiton be, similar to previous exercies (`pod-definition.yaml`)
          metadata: 
            name: myapp-pod
            labels: 
              app: myapp
              type: front-end
          spec:
            containers:
              - name: nginx-container 
                image: nginx
        replicas: 3
        selector: 
          matchLabels:
            type: front-end
      ```
    - create from file
      ```bash
      kubectl create -f deployment-definiton.yml
      ```
    - get info
      ```
      kubectl get all # Get ALL objects created
      kubectl get deployments # get all deployments
      kubectl get replicaset
      kubectl get pods
      ```

### Certification Tip: Formatting Output with kubectl
- Default output format for all **kubectl** commands is human readable plain text format
- We can leverage the `-o` flag to output the details in several different formats
- `kubectl [command] [TYPE] [NAME] -o <output_format>`, some commonly used:
  - -o json: Output a JSON formatted API object.
  - -o name: Print only the resource name and nothing else.
  - -o wide: Output in the plain-text format with any additional information.
  - -o yaml: Output a YAML formatted API object.
- Helpful links
  - https://kubernetes.io/docs/reference/kubectl/
  - https://kubernetes.io/docs/reference/kubectl/quick-reference/
  - https://kubernetes.io/docs/reference/kubectl/jsonpath/

### Recap: Namespaces
- ![kubernetes_namespace](./resources/images/material/kubernetes_namespace.png)
- House analogy: each namespace is a house, within each house they call each other by the first name, by call people from other house by their full name. 
- By default startup, kubernetes creates 3 namespace
  - `Default`: this is where all your objects by default will be created
  - `kube-system`: internal services such as networking solution, dns service etc
  - `kube-public`: resources that should be made available for users are created
- Namespace is used for: 
  - Isolation
    - for example: you want to use same cluster for `dev` and `prod` but want to isolate the resources for each env. Can create `dev` and `prod` namespaces
  - Policies: define who can do what
  - Resource Limits: limit resource for each namespace (cpu, memory, i/o, etc)
  - DNS: resources within a namespace can refer to each other simply by their names 
    - e.g. From your own namespace: `mysql.connect("db-service")`
    - e.g. From other namespace (default to dev): `mysql.connect("db-service.dev.svc.cluster.local")`
    - Format of the DNS name: `db-service.dev.svc.cluster.local`
      - db-service: service name
      - dev: namespace
      - svc: stands for `service`. default subdomain
      - cluster.local: default domain
  - To get by namespace
  ```bash
  kubectl get pods # by default, use default
  kubectl get pods --namespace=kube-system # other namespace use namespace option
  ```
  - Create namespace
    - namespace definiton file
    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: dev
    ```
    - create namespace
    ```bash
    kubectl create -f namespace-dev.yml # from file
    kubectl create namespace dev # directly
    ```
  - Switch default namespace
  ```bash
  kubectl config set-context $(kubectl config current-context) --namespace=dev # this command set-context to one(current-contex) then we set the namespace field to dev
  kubectl get pods
  ```
  - **Note**: will discuss context later
  - View pods in all namespaces
  ```bash
  kubectl get pods --all-namespaces
  ```
  - To limit resource usage within namespace, create `Resource Quota`
  ```yaml
  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: compute-quota
    namespace: dev
  spec:
    hard:
      pods: "10"
      requests.cpu: "4"
      requests.memory: 5Gi
      limits.cpu: "10"
      limits.memory: 10Gi
  ```
  ```bash
  kubectl create -f compute-quota.yaml
  ```

### Practice Test & Solution - Namespace
- Practice: https://uklabs.kodekloud.com/topic/namespaces-3/
- Solution: [practice3_namespace](./practices/practice3_namespace/)

### Certification Tip: Imperative commands
- Declarative(using defitnion file) or Imperative(directly)
- We rarely want to use Imperative, but it is useful to getting one-time tasks done quickly. 
- Two options that can come in handy:
  - `--dry-run`: By default, as soon as the command is run, the resource will be created. If you simply want to test your command, use the `--dry-run=client `option. This will not create the resource. Instead, tell you whether the resource can be created and if your command is right.
  - `-o yaml`: This will output the resource definition in YAML format on the screen.
- Use the above two in combination along with Linux output redirection to generate a resource definition file quickly, that you can then modify and create resources as required, instead of creating the files from scratch.
  - `kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-pod.yaml`
- Example: POD
  - create an NGINX Pod: `kubectl run nginx --image=nginx`
  - generate POD manifest YAML file (-o yaml): `kubectl run nginx --image=nginx --dry-run=client -o yaml`
- Example: Service
  - Create a `Service` named redis-service of type ClusterIP to expose pod redis on port 6379
  ```bash
  kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml # this will use pod's label as selectors

  kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml # this will assuem selectors as app=redis. 

  # you cannot pass selector as option: https://github.com/kubernetes/kubernetes/issues/46191
  ```
  - Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes
  ```bash
  kubectl expose pod nginx --port=80 --name nginx-service --type=NodePort --dry-run=client -o yaml # with this can't specify the node port, have to manually add (but preferred than using create dry run)

  kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml # this will not use pods label as selectors
  ```
- Reference: https://kubernetes.io/docs/reference/kubectl/conventions/ 

### Practice Test & Solution - Imperative Commands
- Practice: https://kodekloud.com/topic/imperative-commands/
- Solution: [practice4_imperative_commands](./practices/practice4_imperative_commands/)

## Configuration

### Define, build, and modify contianer images
- Why need to build our own:
  - if there is no existing image in registry that fulfils your service needs
  - ease of shipping and deployment
- To create an image
  - create `Dockerfile`: for [reference](https://docs.docker.com/reference/dockerfile/)
  - docker build: `docker build Dockerfile -t <account-name/image-name>`
    - failure: upon failure, docker will cache previous successful step, and will continue directly from last failed step
  - docker push: `docker push <acount-name/image-name>`
  - *Note*:
    - use `docker history <account-name/image-name>` after buld to see the detail of each step in Dockerfile process (e.g. how much storage they use)

### Practice Test & Solution: Docker Images
- Practice: https://uklabs.kodekloud.com/topic/practice-test-docker-images-2/
- Solution: [practice5_images](./practices/practice5_images/)

### Commands and Arguments in Doccker
- Note: a container only lives as long as the process is alive. Meaning if process stop, containers exited. What is the process that allow the container to live? Answer: the `CMD` or `ENTRYPOINT` inside the dockerfile (e.g. `CMD ["bash"]` meaning the container alive as long as the bash process is running)
- How to specify different command to start the container: append command to `docker run` command (e.g. `docker run ubuntu sleep 5` override the bash, making the container to sleep for 5 seconds then exits)
- How to make this change (`sleep 5`) permanent?
  - make a Dockerfile
  ```yaml
  FROM Ubuntu
  CMD sleep 5
  ```
  - can also use json array format (separate command and argument)
    ```yaml
    FROM Ubuntu
    CMD ["sleep", "5"]
    ```
  - build: `docker build -t ubuntu-sleeper`
  - run: `docker run ubuntu-sleeper`
- Pass in argument (e.g. sleep for x argument seconds). use `ENTRYPOINT` instead of `CMD`
```yaml
FROM Ubuntu
ENTRYPOINT ["sleep"]
```
- Default value (if no `x` argument passed when `docker run ubuntu-sleeper x`, will return error). combine `ENTRYPOINT` and `CMD`
```yaml
FROM Ubuntu
ENTRYPOINT ["sleep"]
CMD ["5"]
```
- Change base command to run (e.g. `sleep` to `sleep2.0`)
  - run: `docker run --entrypoint sleep2.0 ubuntu-sleeper 10`

### Commands and Arguments in Kubernetes
- create pod from `ubuntu-sleeper` from previous section
  - create `pod-definition.yml`
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: ubuntu-sleeper-pod
  spec:
    containers:
      - name: ubuntu-sleeper
        image: ubuntu-sleeper
        command: ["sleep2.0"] #override the ENTRYPOINT ["sleep"]
        args: ["10"] # override the CMD ["5"]
  ```
  - create pod
  ```bash
  kubectl create -f pod-definition.yml
  ```

### Practice Test & Solution: Commands and Arguments
- Practice: https://uklabs.kodekloud.com/topic/commands-and-arguments/
- Solution: [practice6_command_argument](./practices/practice6_command_argument/)

### Environment Variables
- `env` property in `.yaml` file. `env` is an array that takes a key(`name`)-value pair
  ```yaml
  apiVersion: v1 
  kind: Pod 
  metadata:
    name: ubuntu-pod
  spec:
    containers:
    - name: ubuntu
      image: ubuntu
      env:
        - name: COLOR
          value: pink
  ```
- Other ways of setting in environment variables
  - ConfigMaps (upcoming lecture)
  ```yaml
  env:
    - name: COLOR
      valueFrom:
            configMapKeyRef:
  ```
  - Secrets (upcoming lecture)
  ```yaml
  env:
    - name: COLOR
      valueFrom:
            secretKeyRef:
  ```

### ConfigMaps
- Motivation: when we have many pod definition files, can be hard to manage the environment variables
- ConfigMaps: pass configuration data in form of key-value pair to created pod
- 2 Phases:
  - Create ConfigMap
    - Imperative way:
    ```bash
      # literal format: <config-name> --from-literal=<key>=<value> 
      kubectl create configmap \
        app-config --from-literal=APP_COLOR=blue
        app-config --from-literal=APP_MOD=prod
      
      # from file format: <config-name> --from-file=<path-to-file>
      kubectl create configmap
        app-config --from-file=app_config.properties
    ```
    - Declarative way:
      - `config-map.yaml`
      ```yaml
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: app-config
      data:
        APP_COLOR: blue
        APP_MOD: prod
      ```
  - Inject them into pod
    - pod-definition.yaml (for all key-value pair of ConfigMap):  use `envFrom` -> `configMapRef` -> `name`. Where the `name` is the `name` metadata from ConfigMap definition
      ```yaml
      apiVersion: v1 
      kind: Pod 
      metadata:
        name: ubuntu-pod
      spec:
        containers:
        - name: ubuntu
          image: ubuntu
          envFrom:
            - configMapRef:
                name: app-config
      ```
    - pod-definition.yaml (for a single key-value pair of ConfigMap): use `env` property
      ```yaml
      apiVersion: v1 
      kind: Pod 
      metadata:
        name: ubuntu-pod
      spec:
        containers:
        - name: ubuntu
          image: ubuntu
          env:
            - configMapRef:
                name: app-config
                key: APP_COLOR
      ```
    - for volumes
      ```yaml
      volumes:
        - name: app-config-volume
          configMap:
            name: app-config
      ```
    - config-map.yaml
      ```yaml
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: app-config
      data:
        APP_COLOR: blue
        APP_MOD: prod
      ```
- View ConfigMaps:
  - `kubectl get configmaps`
  - `kubectl describe configmaps`

### Practice Test & Solution: ConfigMaps
- Practice: https://uklabs.kodekloud.com/topic/configmaps-2/
- Solution: [practice7_config_maps](./practices/practice7_config_maps/)

### Kubernetes Secrets
- Motivation: ConfigMap stored key-value pair in plain text data (not okay to store sensitive information like password and keys)
- Secret: similar to ConfigMap but used to store sensitive data
- 2 Phase:
  - Create Secret
    - Imperative way:
      - Secret file(for `fromfile`):
      ```
      DB_HOST: mysql
      DB_User: root
      DB_Password: password
      ```
      ```bash
      # literal format: <secret-name> --from-literal=<key>=<value>
      kubectl create secret generic\
        app-secret --from-literal=DB_HOST=mysql
        app-secret --from-literal=DB_Password=passwrod

      # from file format: <secret-name> --from-file=<path-to-file>
      kubectl create secret generic\
        app-secret --from-file=app_secret.properties
      ```
    - Declarative way:
      - secret-data.yaml
      ```yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: app-secret
      data:
        DB_Host: bXlzcWw=
        DB_User: cm9vdA==
        DB_Password: cGFzc3dvcmQ=
      ```
      - we encode the value before storing it
      ```bash
      echo -n mysql | base64 #output: bXlzcWw=
      ```
      - to decode back
      ```bash
      echo -n bXlzcWw= | base64 --decode
      ```
  - Inject to Pod
    - pod-definition.yaml (injecting all key-value pair)
      ```yaml
      apiVersion: v1 
      kind: Pod 
      metadata:
        name: ubuntu-pod
      spec:
        containers:
        - name: ubuntu
          image: ubuntu
          envFrom:
            - secretRef:
                name: app-secret
      ```
    - single env: use `env` property
    ```yaml
    env:
      - name: DB_Password
        valueFrom:
          secretKeyRef:
            name: app-secret
            key: DB_Password
    ```
    - Volume: the secret will be created as files with value of secrets as its content
      - e.g. `ls /opt/app-secret-volumes` -> DB_Host, DB_Password, DB_User
      - where each file contains the value of the key
    ```yaml
    volumes:
      - name: app-secret-volume
        secret:
          secretName: app-secret
    ```
    - secret-data.yaml
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata: 
      name: app-secret
    data: 
      DB_Host: bXlzcWw=
      DB_User: cm9vdA==
      DB_Password: cGFzc3dvcmQ=
    ```
    - create the secret
    ```bash
    kubectl create -f pod-definition.yaml
    ```
- View Secrets:
  - `kubectl get secrets`
  - `kubectl describe secrets`
  - To view the valueL `kubectl get secret app-secret -o yaml`
- Note on Secrets:
  - Secrets only encoded. Not encrypted
    - Do not check-in Secret objects to SCM along with the code
  - Secrets are not encrypted in ETCD
    - Suggestted to encrypt secret at Rest
  - Anyone able to create pods/deployments in the same namespace can access the secrets
  - Consider third party secrets store providers (AWS ,Azure, GCP, Vault Provider)
- Additional Notes: https://www.udemy.com/course/certified-kubernetes-application-developer/learn/lecture/14827458#content
  
### Secret Store CSI Driver
https://www.youtube.com/watch?v=MTnQW9MxnRI

### Practice Test & Solution: Secrets
- Practice: https://uklabs.kodekloud.com/topic/secrets-4/
- Solution: [practice8_secrets](./practices/practice8_secrets/)

### Demo: Encrypting Secret Data at Rest
- Resource: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

### Docker Security
- Container and host share the same kernel. Container use namespace, each containers has it's own namespace, and each container can only see processes of its own namespace. But the host (also its own namespace), but since all containers run inside host's namespace, technically from host perspective, it can see all the processes run by each container it host (different PID from the container's PID). This is process isolation.
- User Isolation: by default, docker run process in container as root user (can check using `ps aux`) To run process to not run as root can use option `--user`
  ```bash
  docker run --user=1000 ubuntu sleep 3600
  ```
  - or user can be defined in the image
    - e.g. Dockerfile
      ```Dockerfile
      FROM UBUNTU
      USER 1000
      ```
    - build image: `docker build -t my-ubuntu-imag .`
    - run container using image: `docker run my-ubuntu-image sleep 3600`
  - But docker uses Linux Capabilities: basically it limits the capability even for root user when it runs on container
    - can check in `/usr/include/linux/capability.h`
    - override privilege: `docker run --cap-add MAC_ADMIN ubuntu`
    - drop privileege: `docker run --cap-drop kill ubuntu`

### Security Contexts
- Similar to previous section on Docker security user isolation, we can do the same in k8s with security contexts
- In k8s, container is isolated within pods
  - if user isolation setting in the pod: applies to all containers
  - if both container and pod apply user isolation setting: setting in container override the pod's setting
- Pod level:
```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: web-pod
spec:
  securityContext:
    runAsUser: 1000
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["sleep", "3600"]
```
- Container level:
```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: web-pod
spec:
  containers:
    - name: ubuntu
      image: ubuntu
      command: ["sleep", "3600"]
      securityContext:
        runAsUser: 1000
        capabilities: # capabilities only supported in container level and not pod level
          add: ["MAC_ADMIN"]
```

### Practice Test - Security Contexts
- Practice: https://uklabs.kodekloud.com/topic/security-contexts-3/ 
- Solution: [practice9_security_contexts](./practices/practice9_security_contexts/)

### Service Accounts
- Linked with other security related concepts such as auth, RBAC, etc
- But, for CKAD course, we need to only know how to use Service Accounts
- 2 Types of Accounts
  - User Account (Human)
    - e.g. Admin accessing cluster to perform some task or dev accessing cluster to deploy application
  - **Service Account** (Machine)
    - e.g. Monitoring application like prometheus use service account to poll k8s API
- To create a Service Account
  - Imperative:
    ```bash
    kubectl create serviceaccount dashboard-sa
    kubectl get serviceaccount # by default, each namespace has its own `default` service account
    kubectl describe serviceaccount dashboard-sa # has Tokens property, stored as a secret object (e.g. dashboard-sa-token-kbbdm)

    kubectl describe secret dashboard-sa-token-kbbdm # accessing the token in the `token` field
    ```
  - Default service acocunt
    - By default, each namespace has its own `default` service account
    - When you create a new pod (without servie account config), it will automatically mount the `default` service account in the `Volumes` directive (e.g. `default-token-j4hkv`)
    - The `default` service account capability is very limited
    ```bash
    kubectl describe pod my-kubernetes-dashboard #check the Volumes and Mounts section
    kubectl exec -it my-kubernetes-dashboard --ls /var/run/secrets/kubernetes.io/serviceaccount # where the service account is stored
    kubectl exec -it my-kubernetes-dashboard cat /var/run/secrets/kubernetes.io/serviceaccount/token # see the token
    ```
  - Disable of using default service account
  ```yaml
  apiVersion: v1
  kind: Pod
  ...
  spec:
    ...
    automountServiceAccountToken: false # HERE
  ```
  - Use custom service account in pod definiton (need to delete and recreate the pod to take effect)
  ```yaml
  apiVersion: v1
  kind: Pod
  ...
  spec:
    ...
    serviceAccountName: dashboard-sa # HERE
  ```
  - but for deployment, will take care of deleting and recreating with new service account.
  - K8s 1.22/1.24 changes
    - if you go to https://jwt.io/, and paste in the serviceAccount token stored in each pod (e.g. /var/run/secrets/kubernetes.io/serviceaccount/token), notice that the token don't have expiry date
    - `v1.22` Introduced TokenRequestAPI: provisioning k8s serviceAccount token, more secure and scalable
      - Pod not use serviceAccount tokens by default anymore, instead it mounts a projected volume, that communicates and updates the auth token using the TokenRequestAPI
    - `v1.24` Reduction of secret-based serviceAccount tokens
      - when creating a service account, it don't automatically create secret for you
      - for example, to do simulate behavior in the beginning of section (create token, but not secret object that contains token inside)
      ```bash
      kubectl create serviceaccount dashboard-sa
      kubectl create token dashboard-sa # if we copy and decode it in jwt.io, now there is expiry date 
      ``` 
      - To create alongside with secret object that contains token inside (`secret-definition.yml`)
      ```yaml
      apiVersion: v1
      kind: Secret
      type: kubernetes.io/service-account-token
      metadata:
        name: mysecretname
        annotations:
          kubernetes.io/service-account-name: dashboard-sa # have this service-account first
      ```
      - But doing these is not recommended anymore (should only create a service account token if TokenRequestAPI can't be used)

### Practice - Service Accounts
- Practice: https://uklabs.kodekloud.com/topic/service-account-2/
- Solution: [practice10_service_accounts](./practices/practice10_service_accounts/)

### Resource Requirements
- Every pod require a set of resources to run, whenever a pod is place on a node, it consumes the resource from that node
- kube-scheduler decides which node a pod goes to, if no resource availaable in any of the nodes, scheuler will hold on placing node, and pod status will be failed due to "Insufficent cpu" or other resources
- **Request**: To specifiy resource requirement for each pod (Resource Requests)
  - To specify:
  ```yaml
  apiVersion: v1
  kind: Pod
  spec:
    ...
    containers:
    - name: webapp
      ...
      resources:
        requests:
          memory: "4Gi"
          cpu: 2
  ```
  - What does 1 CPU mean?
    - first, it is equivalent to
      - 1 AWS vCPU
      - 1 GCP core
      - 1 Azure Core
      - 1 Hyperthread
    - Lowest it can go is "1M" or 0.001
  - With memory, the unit goes
    - 1 G(Gigabyte) -> 1 M(Megabyte) -> 1 K(Kilobyte) or
    - 1 Gi(Gibibyte)(or equivalent to 1.073741 G) -> 1 Mi -> 1 Ki
- **Limit**: By default a container has no limit on the resources it consumes (meaning given enough time it might consumes the resource of the whole node), so crucial to set limit
  - To specify limit
  ```yaml
  apiVersion: v1
  kind: Pod
  spec:
    ...
    containers:
    - name: webapp
      ...
      resources:
        requests:
          memory: "4Gi"
          cpu: 1
        limits:
          memory: "4Gi"
          cpu: 2
  ```
  - What happened when a pod want to exceed it limits?
    - CPU: not allowed, will be throttled at its limit
    - Memory: a container can go over its defined limit, and pod will be terminated caused of OOM(Out of Memory) error
  - Default Behavior
    - K8s doesn't have request and limit
    - any pod can consume as many resource as they want
  - Behavior/ Cases
    - CPU: 
      - No request, have limits: request = limits
      - Have request, have limits: CPU between request - limits
      - Request, no limits: most ideal setup (case by case), but pod will always have resource guaranteed
    - Memory:
      - No request, have limits: request = limits
      - Have request, have limits
      - Request, no limits: any pod can consume as much memory, if a pod consumes memory too much memory the only way to retrieve it is to kill the pod itself
- `Limit Range`: define default values to containers in pod (define in **namespace** level) 
  - `limit-range-cpu.yaml` (same setup with memory, just use `memory` instead of `cpu`)
  ```yaml
  apiVersion: v1
  kind: LimitRange
  metadata:
    name: cpu-resource-constraint
  spec:
    limits:
    - default: #limit
        cpu: 500m
      defaultRequest: #request
        cpu: 500m
      max:
        cpu: "1"
      min:
        cpu: 100m
      type: Container
  ```
- `Resource Quotas`: restrict total amount of resources used by application deployed in a cluster (**namespace** level object)
  - `resource-quota.yaml`
  ```yaml
  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: my-resource-quota
  spec:
    hard:
      requests.cpu: 4
      requests.memory: 4Gi
      limits.cpu: 10
      limits.memory: 10Gi
  ```

### Practice Test - Resource Requirements
- Practice: https://uklabs.kodekloud.com/topic/resource-limits-2/
- Solution: [practice11_resource_requirements](./practices/practice11_resource_requirements/)

### Taints and Tolerations
- Analogy: bug, human, and bug spray
  - bug spray keeps bug away from human, in this case bugs are intolerant to bug spray.
  - but not all bugs, are intolerant to all bug spray. It all depends on the Intolerant level of the bug and the taint used, some bug can tolerate certain taint
  - in K8s:
    - human: `node`
    - bugs: `pod`
    - bug spray: `taint`
    - it has nothing to do with security, rather restriction on which pod can be scheduled on a node
- Default behavior: all nodes have no taint, and all pods have no toleration. Meaning if a node has a taint, no pod unless given a toleration to that taint is able to get scheduled in that node.
- Taint - Node
  - Create
  ```bash
  kubectl taint nodes node-name key=value:taint-effect # format
  kubectl taint nodes node1 app=blue:NoSchedule # give a taint of key app and value blue, wiht NoScheudle effect
  ```
    - 3 types of taint-effects
      - NoSchedule: pod will not schedule on the node 
      - PreferNoSchedule: pod will not preferable to be schedule on the node (but not guarantee)
      - NoExecute: new pods will not be scheduled on the node and existing pod on the node will be evicted if they don't tolerate to the taint
- Toleration - Pods
  - Create
  ```bash
  kubectl taint nodes node1 app= blue:NoSchedule
  ```
  - `pod-defintion.yaml` :all toleration field value must use dobule quote (`""`)
  ```yaml
  apiVersion: v1
  kind: Pod
  ...
  spec:
    ...
    tolerations:
      - key: "app"
        operator: "Equal"
        value: "blue"
        effect: "NoSchedule"
  ```
- Note: Taint does not ensure that a pod is assiged to that node, a pod with a toleration can be scheduled to any node event those nodes with no taint at all. If the goal is to ensure that a pod goes into certain nodes, we can achieve that using `Node Affinity` in the next section
- Note: master node, the node that is responsible for holding all the management software. Master node don't have any pods on it because when it created, a taint is put onto the master node that prevents any pod to be schedule in it
  - To see it: `kubectl describe node kubemaster | grep Taint`

### Practice Test - Taints and Toleration
- Practice: https://uklabs.kodekloud.com/topic/taints-and-tolerations-3/
- Solution: [practice12_taints_toleration](./practices/practice12_taints_toleration/)

### Node Selectors
- 3 Nodes;