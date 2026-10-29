# kubectl — Kubernetes Command-Line Tool

## 1. What is kubectl?

`kubectl` (pronounced “kube-control” or “kube-C-T-L”) is the command-line tool used to communicate with and manage a Kubernetes cluster.

It allows DevOps engineers to deploy applications, inspect resources, troubleshoot issues, scale workloads, and manage Kubernetes objects.

Example:

```
kubectl get nodes
kubectl get pods
kubectl get deployments
```

Think of `kubectl` as your control interface for Kubernetes. You enter a command, `kubectl` sends a request to the Kubernetes API server, and the cluster processes the request.

## 2. How kubectl works

User / DevOps Engineer

Runs `kubectl` commands

kubectl CLI

Reads configuration and sends API requests

Kubernetes API Server

Authenticates, authorizes and processes requests

Kubernetes Cluster

Resources, controllers, nodes and Pods

For example, when you run `kubectl get pods`, kubectl requests Pod information from the API server and displays the response.

Important: `kubectl` does not directly start containers. Kubernetes components coordinate the work.

## 3. Install and verify kubectl

Check whether kubectl is installed:

```
kubectl version --client
```

Check the current cluster context:

```
kubectl config current-context
```

Check cluster connectivity:

```
kubectl cluster-info
kubectl get nodes
```

If you are using the kubeadm cluster from your previous lesson, run these commands on the control-plane machine after configuring `~/.kube/config`. You can also configure kubectl on your laptop using a securely transferred kubeconfig file.

Official guide: [Install Kubernetes tools](https://kubernetes.io/docs/tasks/tools/?utm_source=chatgpt.com).

## 4. Basic kubectl command syntax

Most commands follow this pattern:

```
kubectl <command> <resource-type> <resource-name> [options]
```

For example:

```
kubectl get pods
kubectl describe pod nginx
kubectl delete pod nginx
```

Here, `get`, `describe`, and `delete` are commands, while `pod` is the resource type and `nginx` is the resource name.

## 5. Most important kubectl commands

These are the commands I recommend writing in your notebook first.

### A. Cluster and node management

| Command                      | Use                               |
| ---------------------------- | --------------------------------- |
| `kubectl cluster-info`       | View cluster endpoint information |
| `kubectl get nodes`          | List nodes                        |
| `kubectl get nodes -o wide`  | Show additional node details      |
| `kubectl describe node NODE` | Inspect a node                    |
| `kubectl version --client`   | Check kubectl version             |

### B. Pods

| Command                       | Use                                                          |
| ----------------------------- | ------------------------------------------------------------ |
| `kubectl get pods`            | List Pods in the current namespace                           |
| `kubectl get pods -A`         | List Pods across all namespaces                              |
| `kubectl get pods -o wide`    | Show Pod IPs and node placement                              |
| `kubectl describe pod POD`    | Inspect a Pod and its events                                 |
| `kubectl logs POD`            | View container logs                                          |
| `kubectl logs POD --previous` | View logs from the previous container instance, if available |
| `kubectl exec -it POD -- sh`  | Open a shell inside a container, if supported                |
| `kubectl delete pod POD`      | Delete a Pod                                                 |

### C. Deployments and scaling

| Command                                         | Use                                             |
| ----------------------------------------------- | ----------------------------------------------- |
| `kubectl get deployments`                       | List Deployments                                |
| `kubectl create deployment nginx --image=nginx` | Create a Deployment                             |
| `kubectl scale deployment nginx --replicas=3`   | Set the desired replica count to three          |
| `kubectl rollout status deployment/nginx`       | Check rollout progress                          |
| `kubectl rollout history deployment/nginx`      | View rollout history                            |
| `kubectl rollout undo deployment/nginx`         | Roll back to a previous revision when available |
| `kubectl delete deployment nginx`               | Delete a Deployment                             |

### D. Services and namespaces

| Command                                                | Use                                               |
| ------------------------------------------------------ | ------------------------------------------------- |
| `kubectl get services`                                 | List Services                                     |
| `kubectl get svc`                                      | Short form of `get services`                      |
| `kubectl get namespaces`                               | List namespaces                                   |
| `kubectl create namespace dev`                         | Create a namespace                                |
| `kubectl get pods -n dev`                              | List Pods in the `dev` namespace                  |
| `kubectl config set-context --current --namespace=dev` | Set the default namespace for the current context |

Remember: `-A` means all namespaces, and `-n dev` means the `dev` namespace.

### E. YAML and resource management

| Command                             | Use                                                |
| ----------------------------------- | -------------------------------------------------- |
| `kubectl apply -f deployment.yaml`  | Create or update resources from YAML               |
| `kubectl get -f deployment.yaml`    | Retrieve resources identified by a manifest        |
| `kubectl delete -f deployment.yaml` | Delete resources described in a manifest           |
| `kubectl diff -f deployment.yaml`   | Preview differences against the live configuration |
| `kubectl explain deployment`        | Learn the fields supported by a resource           |
| `kubectl get pods -o yaml`          | Display a Pod in YAML format                       |

## 6. Hands-on practice: Deploy Nginx

Let's practise using kubectl on your KIND cluster or kubeadm cluster.

Step 1 — Check the cluster

```
kubectl get nodes
```

Make sure your node or nodes show `Ready`.

Step 2 — Create a Deployment

```
kubectl create deployment nginx --image=nginx
```

Step 3 — Check the Deployment and Pods

```
kubectl get deployments
kubectl get pods -o wide
```

Step 4 — Scale the application

```
kubectl scale deployment nginx --replicas=3
```

Verify:

```
kubectl get pods
kubectl get deployments
```

You should see three desired replicas, and eventually three running Pods if the cluster has enough resources and no errors.

Step 5 — Inspect a Pod

Get the actual Pod name:

```
kubectl get pods
```

Then run:

```
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

Replace `<pod-name>` with the name shown in your terminal.

Step 6 — Expose Nginx inside the cluster

```
kubectl expose deployment nginx \
  --port=80 \
  --target-port=80
```

Check the Service:

```
kubectl get svc
```

This creates a ClusterIP Service by default. It is accessible inside the cluster, but it does not automatically expose Nginx to the public internet.

Step 7 — Clean up

```
kubectl delete service nginx
kubectl delete deployment nginx
```

## 7. Imperative vs declarative commands

Kubernetes resources can be managed imperatively or declaratively.

| Imperative approach                                      | Declarative approach                        |
| -------------------------------------------------------- | ------------------------------------------- |
| Direct commands describe an action                       | YAML describes the desired state            |
| Good for quick tasks and learning                        | Good for repeatable deployments and GitOps  |
| Example: `kubectl create deployment nginx --image=nginx` | Example: `kubectl apply -f deployment.yaml` |

For real DevOps projects, learn to use YAML manifests and `kubectl apply` because they make configurations easier to version-control in Git and reuse through CI/CD pipelines.

## 8. Troubleshooting with kubectl

| Problem                    | Commands to start with                                        |
| -------------------------- | ------------------------------------------------------------- |
| Pod stuck in `Pending`     | `kubectl describe pod POD`                                    |
| Pod in `CrashLoopBackOff`  | `kubectl logs POD` and `kubectl logs POD --previous`          |
| Image pull failure         | `kubectl describe pod POD`                                    |
| Deployment not progressing | `kubectl rollout status deployment/NAME`                      |
| Service not working        | `kubectl get svc` and `kubectl get endpointslices`            |
| Node not ready             | `kubectl describe node NODE`                                  |
| Need recent cluster events | `kubectl get events -A --sort-by=.metadata.creationTimestamp` |

Interview tip: Start with `kubectl get`, then use `kubectl describe` for events and configuration details, and `kubectl logs` for application errors.

## 9. Interview questions

1\. What is kubectl?

A CLI tool for interacting with Kubernetes clusters through the Kubernetes API.

2\. What is the difference between `kubectl get` and `kubectl describe`?

`get` provides a concise resource listing or representation. `describe` provides detailed information, including conditions and events where applicable.

3\. What is the difference between `kubectl apply` and `kubectl create`?

`create` imperatively creates a resource and normally fails if that named resource already exists. `apply` manages resources from configuration files and can update existing resources.

4\. How do you view logs from a crashing container?

```
kubectl logs POD --previous
```

This works when a previous container instance exists and its logs remain available.

5\. How do you scale a Deployment?

```
kubectl scale deployment nginx --replicas=3
```

6\. How do you switch Kubernetes clusters?

```
kubectl config get-contexts
kubectl config use-context <context-name>
```

Always verify your current context before running commands that change or delete resources.

## Quick revision

Remember these six commands first:

```
kubectl get nodes
kubectl get pods -A
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl apply -f deployment.yaml
kubectl get deployments
```

Once these feel comfortable, the next useful topic is Pods in Kubernetes: Pod lifecycle, YAML manifests, labels, container states, and practical troubleshooting.