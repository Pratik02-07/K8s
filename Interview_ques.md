# Interview Questions
### 1: Monolithic vs Microservices Architecture
Q1. What is monolithic architecture?

A software architecture in which the major application components are packaged and deployed as one integrated unit.

Q2. What is microservices architecture?

An architecture in which an application is divided into small, independently deployable services that communicate through APIs or messaging.

Q3. Why are microservices useful in DevOps?

They enable independent deployment and scaling, allowing teams to release and operate individual services without necessarily redeploying the entire application.

Q4. Can Kubernetes run a monolithic application?

Yes. Kubernetes can deploy, scale, and manage monolithic applications as well as microservices.

Q5. Do microservices always use separate databases?

No. Independent data ownership is a common design principle, but implementations vary. Sharing a database can introduce coupling between services.

Q6. Which architecture is better?

Neither is universally better. Monoliths are often simpler for small applications, while microservices can be beneficial for larger systems that need independent development, deployment, and scaling.


Quick Revision
- Monolith: One integrated application, usually deployed as a single unit.
- Microservices: Multiple independently deployable services working together.
- DevOps benefit: Microservices can enable independent releases and scaling.
- Kubernetes role: Orchestrates containers for either architecture.

----
### 2: K8s Architecture.
Q1. What is the difference between the control plane and a worker node?

The control plane manages the cluster and makes scheduling and reconciliation decisions. Worker nodes run the application Pods.

Q2. What is the role of etcd?

It stores Kubernetes cluster state and configuration as a consistent key-value store.

Q3. What is the difference between kubelet and kube-proxy?

Kubelet manages the Pods assigned to a node. Kube-proxy traditionally configures Service networking rules to direct traffic toward backend Pods.

Q4. What does the scheduler do?

It selects an appropriate node for each newly created Pod that needs scheduling.

Q5. Does kubectl run containers directly?

No. kubectl sends requests to the API server. Kubernetes controllers, the scheduler, kubelet, and the container runtime perform the subsequent work.

Q6. What happens if a container crashes?

The kubelet and container runtime work to restart it according to the Pod's restart policy. Higher-level controllers, such as Deployments, also help maintain the desired number of Pods.

Q7. Is Kubernetes the same as Docker?

No. Docker is associated with building and working with container images and containers. Kubernetes orchestrates containerized applications across a cluster. Kubernetes commonly uses a runtime such as containerd.
Quick Revision
- Control Plane: manages cluster state and orchestration.
- API Server: main Kubernetes API entry point.
- etcd: stores cluster state.
- Scheduler: chooses a node for an unscheduled Pod.
- Controller Manager: reconciles desired and actual state.
- Kubelet: manages Pods on a node.
- Kube-proxy: traditionally implements Service networking rules.
- Container Runtime: runs containers.
- kubectl: CLI for interacting with Kubernetes through the API.
---

### 3: 
