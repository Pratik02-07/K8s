# Kubernetes Deployments — Notes, Commands & Practical

## 1. What is a Deployment?

A Deployment is a Kubernetes resource that manages and maintains a desired number of replicated Pods. It also supports application updates and rollbacks.

Instead of creating and managing Pods one by one, you define a Deployment and Kubernetes works to keep the desired number of Pods running.

Example: Suppose your application needs three Nginx Pods. You create a Deployment with `replicas: 3`. If one Pod fails or is deleted, Kubernetes works to create a replacement.

## 2. How a Deployment works

![Deployments](<./image.png>)

The relationship is:

- Deployment: manages application rollout and the desired state.
- ReplicaSet: maintains the desired number of matching Pods.
- Pods: run the application containers.

The Deployment normally creates and manages a ReplicaSet, which creates and manages the Pods.

## 3. Why do we need Deployments?

Imagine you manually create three Pods for your application. If a Pod gets deleted, Kubernetes won't recreate that standalone Pod automatically.

With a Deployment, Kubernetes continuously works to maintain the desired number of replicas.

Key benefits:

- Self-healing: replaces missing Pods to restore the desired replica count.
- Scaling: increases or decreases the number of replicas.
- Rolling updates: updates application versions gradually.
- Rollback: returns to a previous Deployment revision when available.
- Declarative management: stores the desired configuration in YAML.

## 4. Create a Deployment using kubectl

Let's deploy Nginx on your KIND or kubeadm cluster.

Step 1 — Check your cluster

```
kubectl get nodes
```

Step 2 — Create a Deployment

```
kubectl create deployment nginx --image=nginx
```

Step 3 — Check the Deployment

```
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

Step 4 — Scale to three replicas

```
kubectl scale deployment nginx --replicas=3
```

Verify:

```
kubectl get deployments
kubectl get pods -o wide
```

Expected Deployment status:

```
NAME    READY   UP-TO-DATE   AVAILABLE
nginx   3/3     3            3
```

The exact output may vary while Pods are starting.

Step 5 — Test self-healing

Find one of the Nginx Pod names:

```
kubectl get pods
```

Delete that Pod:

```
kubectl delete pod <pod-name>
```

Now run:

```
kubectl get pods -w
```

Kubernetes should create a replacement Pod to maintain the desired replica count. Press `Ctrl+C` to stop watching.

## 5. Create a Deployment using YAML

In DevOps, YAML manifests are preferred for repeatable, version-controlled deployments.

Create `deployment.yaml`:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:stable
          ports:
            - containerPort: 80
```

Apply the manifest:

```
kubectl apply -f deployment.yaml
```

Verify:

```
kubectl get deployment nginx
kubectl get rs
kubectl get pods --show-labels
```

Understand the most important YAML fields:

| Field                      | Purpose                                             |
| -------------------------- | --------------------------------------------------- |
| `apiVersion: apps/v1`      | Deployment API version                              |
| `kind: Deployment`         | Specifies the resource type                         |
| `replicas: 3`              | Desired number of Pods                              |
| `selector.matchLabels`     | Selects Pods managed by the Deployment's ReplicaSet |
| `template`                 | Defines the Pod template                            |
| `template.metadata.labels` | Labels applied to created Pods                      |
| `containers.image`         | Container image to run                              |

Important interview point: The labels in the Pod template must match the Deployment selector. Otherwise, the Deployment configuration will be invalid or fail to manage the intended Pods.

## 6. Scaling a Deployment

Scaling changes the desired number of Pod replicas.

Scale up:

```
kubectl scale deployment nginx --replicas=5
```

Scale down:

```
kubectl scale deployment nginx --replicas=2
```

Check:

```
kubectl get deployment nginx
kubectl get pods
```

Scaling creates or removes replicas. It does not change the container image version.

## 7. Rolling updates

A rolling update gradually replaces old Pods with new ones when you update the Deployment's Pod template.

For example, change the Nginx image:

```
kubectl set image deployment/nginx nginx=nginx:1.28
```

Monitor the update:

```
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
```

The version tag is an example; select an image version appropriate for your application.

### Rollback

If the update causes problems and a previous revision is available:

```
kubectl rollout undo deployment/nginx
```

Verify the rollout:

```
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
```

Note: Rollback restores a previous Pod template revision. It does not automatically reverse external database migrations or other changes made outside the Deployment.

## 8. Useful Deployment commands

| Command                                       | Use                                   |
| --------------------------------------------- | ------------------------------------- |
| `kubectl get deployments`                     | List Deployments                      |
| `kubectl describe deployment nginx`           | Inspect Deployment details and events |
| `kubectl edit deployment nginx`               | Edit a Deployment interactively       |
| `kubectl scale deployment nginx --replicas=3` | Scale replicas                        |
| `kubectl rollout status deployment/nginx`     | Check rollout progress                |
| `kubectl rollout history deployment/nginx`    | View rollout revisions                |
| `kubectl rollout undo deployment/nginx`       | Roll back to a previous revision      |
| `kubectl delete deployment nginx`             | Delete the Deployment                 |

## 9. Pod vs ReplicaSet vs Deployment

| Feature                 | Pod                      | ReplicaSet                         | Deployment                       |
| ----------------------- | ------------------------ | ---------------------------------- | -------------------------------- |
| Runs containers         | Yes                      | Indirectly, through Pods           | Indirectly, through ReplicaSets  |
| Maintains replica count | No                       | Yes                                | Yes, through ReplicaSets         |
| Rolling updates         | No                       | No built-in rollout management     | Yes                              |
| Rollback support        | No                       | Not as a rollout history mechanism | Yes                              |
| Typical use             | Individual workload unit | Replica management                 | Application lifecycle management |

In most ordinary application deployments, you create a Deployment rather than creating a ReplicaSet or Pods manually.

## 10. Practical checklist

Deployment lab

- [ ] Create an Nginx Deployment

- [ ] Scale it to three replicas

- [ ] Inspect the ReplicaSet and Pods

- [ ] Delete a Pod and observe self-healing

- [ ] Update the container image

- [ ] Monitor the rolling update

- [ ] Perform a rollback

- [ ] Delete the Deployment

- [ ] Cleanup command:

```
kubectl delete deployment nginx
```

Quick revision: Deployment → manages ReplicaSet → maintains Pods. Deployments support scaling, self-healing through their ReplicaSets, rolling updates, and rollbacks.
