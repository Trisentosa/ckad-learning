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
    - [Solution - ReplicaSets](#solution---replicasets)


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

### Solution - ReplicaSets
