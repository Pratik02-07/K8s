# Kubernetes Pods — Notes, Commands & Practical

## 1. What is a Pod?

A Pod is the smallest deployable unit in Kubernetes. It represents one or more containers that run together and share certain resources, such as a network namespace and optionally shared storage.

Kubernetes usually runs application containers inside Pods rather than managing individual containers directly.

For example, if you deploy an Nginx web server to Kubernetes, the Nginx container runs inside a Pod.

Kubernetes Cluster

Worker Node

Pod: nginx-pod

Nginx Container

Runs the web server

## 2. Why do we need Pods?

Containers need a way to run within Kubernetes and communicate with other workloads. Pods provide the Kubernetes unit for scheduling and running those containers.

Key characteristics:

- A Pod can contain one or multiple containers.
- Containers in the same Pod share the Pod's IP address and network namespace.
- Containers can communicate with one another through `localhost`.
- Containers can share volumes when configured.
- A Pod is scheduled onto one node at a time; its containers run together on that node.
- Pods are relatively disposable. If a Pod fails or is replaced, the replacement can have a different name and IP address.

Interview point: A Pod is not the same as a container. A Pod is the Kubernetes wrapper that defines how one or more containers run together.

## 3. Single-container Pod vs multi-container Pod

![Single-container Pod](<./Single-container Pod.png>)

Single-container Pod

One Pod contains one application container, such as Nginx.

Most common pattern for beginner workloads.

![Multi-container Pod](<./multi-container Pod.png>)

Multi-container Pod

Two or more containers work closely together, sharing the Pod's network and optionally volumes.

Example: an application container with a logging sidecar.

Containers should usually share a Pod only when they need to be tightly coupled. Independent application components generally belong in separate Pods.

## 4. Create your first Pod using kubectl

Use your existing KIND cluster or kubeadm cluster.

Step 1 — Verify cluster access

```
kubectl get nodes
```

Step 2 — Create an Nginx Pod

```
kubectl run nginx-pod --image=nginx
```

Step 3 — Check the Pod

```
kubectl get pods
kubectl get pods -o wide
```

The `-o wide` option shows extra details, including the Pod IP and the node where it runs.

Step 4 — Get detailed information

```
kubectl describe pod nginx-pod
```

This shows the Pod's configuration, container state, events, and other troubleshooting information.

Step 5 — View container logs

```
kubectl logs nginx-pod
```

Nginx may not produce much output until it receives requests.

Step 6 — Delete the Pod

```
kubectl delete pod nginx-pod
```

This removes the standalone Pod. Kubernetes will not automatically recreate it because you created it directly rather than through a controller.

## 5. Create a Pod using YAML

In DevOps, you will frequently define Kubernetes resources in YAML files and store them in Git.

Create a file named `pod.yaml`:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:stable
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "500m"
          memory: "256Mi"
      ports:
        - containerPort: 80

```

Apply the manifest:

```
kubectl apply -f pod.yaml
```

Verify the Pod:

```
kubectl get pod nginx-pod
kubectl describe pod nginx-pod
```

To delete the resource defined in the manifest:

```
kubectl delete -f pod.yaml
```

### Understand the YAML fields

| Field             | Meaning                                                   |
| ----------------- | --------------------------------------------------------- |
| `apiVersion: v1`  | API version for a Pod                                     |
| `kind: Pod`       | Resource type                                             |
| `metadata.name`   | Pod name                                                  |
| `metadata.labels` | Key-value labels used for selection and organization      |
| `spec`            | Desired Pod configuration                                 |
| `containers`      | List of containers in the Pod                             |
| `image`           | Container image to run                                    |
| `containerPort`   | Documents the port the container is expected to listen on |

Important: `containerPort: 80` does not automatically expose the application to your laptop or the internet. You need a networking mechanism, such as port forwarding or a Service, for access.

## 6. Pod lifecycle and status

A Pod moves through different phases during its lifecycle.

| Phase or status | Meaning                                                 |
| --------------- | ------------------------------------------------------- |
| `Pending`       | Waiting for scheduling or setup, such as image download |
| `Running`       | Bound to a node, with containers starting or running    |
| `Succeeded`     | All containers completed successfully                   |
| `Failed`        | All containers have terminated, and at least one failed |
| `Unknown`       | Kubernetes cannot reliably determine the Pod's state    |

You may also see container states or status reasons such as `CrashLoopBackOff`, `ImagePullBackOff`, and `ErrImagePull`. These are not Pod phases; they describe specific container or image-pull problems.

Check the current state:

```
kubectl get pods
kubectl describe pod nginx-pod
```

## 7. Access an application inside a Pod

For local testing, use port forwarding:

```
kubectl port-forward pod/nginx-pod 8080:80
```

Keep that terminal running. Then open `http://localhost:8080` in your browser on the same machine where the command is running.

The mapping means:

- Local port: `8080`
- Pod port: `80`

Stop port forwarding with `Ctrl+C`.

For a long-running application, a Service is normally a better way to provide stable network access than relying on a Pod's IP address.

## 8. Pod vs Deployment

This is a very important interview topic.

| Pod                                                        | Deployment                                            |
| ---------------------------------------------------------- | ----------------------------------------------------- |
| Runs one or more containers                                | Manages a set of replicated Pods                      |
| A standalone Pod is not automatically recreated if deleted | Recreates Pods to maintain the desired replica count  |
| Suitable for learning and some specialized workloads       | Common choice for stateless applications              |
| Pod identity and IP may change when replaced               | Provides controlled rollout and rollback capabilities |

For example, a Deployment can maintain three Nginx replicas:

```
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl get pods
```

Kubernetes will aim to maintain three replicas. The Deployment manages ReplicaSets, which in turn manage the Pods.

## 9. Troubleshooting common Pod issues

| Problem                               | First command to try                                       |
| ------------------------------------- | ---------------------------------------------------------- |
| Pod stuck in `Pending`                | `kubectl describe pod POD`                                 |
| Container repeatedly crashes          | `kubectl logs POD --previous`                              |
| Image cannot be pulled                | `kubectl describe pod POD`                                 |
| Need current logs                     | `kubectl logs POD`                                         |
| Need to inspect a Pod's configuration | `kubectl get pod POD -o yaml`                              |
| Need to inspect recent events         | `kubectl get events --sort-by=.metadata.creationTimestamp` |

Replace `POD` with the actual Pod name. For multi-container Pods, specify the container using `-c CONTAINER_NAME`.

## Practical checklist


- [ ] Create a standalone Nginx Pod

- [ ] Inspect it using kubectl describe

- [ ] Read container logs

- [ ] Create a Pod from pod.yaml

- [ ] Test it using kubectl port-forward

- [ ] Delete the Pod and YAML resource

- [ ] Create a Deployment with three replicas
