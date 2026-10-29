# Kubernetes Namespaces — Notes, Commands & Practical

## 1. What is a Namespace?

A Namespace in Kubernetes is a logical way to divide a single cluster into separate environments or groups of resources.

It helps organize and manage resources such as Pods, Deployments, Services, ConfigMaps, and Secrets within the same cluster.

For example, a company may use one Kubernetes cluster for three environments:

- `dev` — development and testing
- `uat` — user acceptance testing
- `prod` — production applications

Each environment can have its own resources in a separate namespace.

Kubernetes Cluster

dev

Pods

Services

Deployments

uat

Pods

Services

Deployments

prod

Pods

Services

Deployments

Resources are logically separated, but all namespaces share the cluster's underlying infrastructure.

Interview definition: A namespace provides a scope for names and a mechanism to organize resources within a Kubernetes cluster. It can also be used with RBAC and resource quotas to help separate teams and workloads.

## 2. Default namespaces in Kubernetes

When you create a Kubernetes cluster, several namespaces are normally available by default.

| Namespace         | Purpose                                                                                                    |
| ----------------- | ---------------------------------------------------------------------------------------------------------- |
| `default`         | Used when no namespace is specified                                                                        |
| `kube-system`     | Contains Kubernetes system components and related resources                                                |
| `kube-public`     | Publicly readable namespace by default, intended for information that should be visible across the cluster |
| `kube-node-lease` | Contains Lease objects used for node heartbeats                                                            |

Check your cluster:

```
kubectl get namespaces
```

Short form:

```
kubectl get ns
```

Example output:

```
NAME              STATUS   AGE
default           Active   ...
kube-node-lease   Active   ...
kube-public       Active   ...
kube-system       Active   ...
```

Your cluster may contain additional namespaces created by tools or applications.

## 3. Create and manage namespaces

### Create a namespace

```
kubectl create namespace dev
kubectl create namespace uat
kubectl create namespace prod
```

Verify:

```
kubectl get ns
```

### Get resources from a specific namespace

```
kubectl get pods -n dev
kubectl get deployments -n prod
kubectl get services -n uat
```

The `-n` option is short for `--namespace`.

### Describe a namespace

```
kubectl describe namespace dev
```

### Delete a namespace

```
kubectl delete namespace dev
```

Warning: Deleting a namespace deletes the namespaced resources inside it, including its Pods, Deployments, and Services. Don't delete `default`, `kube-system`, or other system namespaces as routine cleanup.

## 4. Deploy an application inside a namespace

Let's create an Nginx Deployment in the `dev` namespace.

Step 1 — Create the namespace

```
kubectl create namespace dev
```

Step 2 — Create the Deployment

```
kubectl create deployment nginx \
  --image=nginx \
  -n dev
```

Step 3 — Verify the resources

```
kubectl get deployments -n dev
kubectl get pods -n dev
```

Step 4 — Compare with the default namespace

```
kubectl get pods
kubectl get pods -n dev
```

The first command checks the `default` namespace. The second checks `dev`.

Step 5 — Delete the practice resources

```
kubectl delete deployment nginx -n dev
kubectl delete namespace dev
```

If you delete the namespace, Kubernetes will remove the Deployment and its associated namespaced resources, so deleting the Deployment first is optional in this example.

## 5. Set a default namespace for kubectl

Repeatedly typing `-n dev` can become inconvenient.

You can set the namespace on your current context:

```
kubectl config set-context --current --namespace=dev
```

Now these commands target `dev` by default:

```
kubectl get pods
kubectl get deployments
```

Check the current context:

```
kubectl config view --minify
```

Switch back to `default` when needed:

```
kubectl config set-context --current --namespace=default
```

This changes your local kubectl context setting, not the namespace of the cluster itself.

## 6. Create a namespace using YAML

In DevOps projects, namespace definitions are often stored in Git and applied through deployment pipelines.

Create `namespace.yaml`:

```
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

Apply it:

```
kubectl apply -f namespace.yaml
```

Verify:

```
kubectl get namespace dev
```

This is the declarative approach: the YAML describes the desired resource.

## 7. Important namespace concepts

Namespaces do not create separate clusters. They provide logical separation inside one cluster. Nodes and underlying cluster resources remain shared.

Namespaces are not automatically security boundaries. RBAC controls who can access resources, and NetworkPolicies can restrict Pod traffic when supported by the network plugin and correctly configured.

Not every Kubernetes resource is namespaced. Pods, Deployments, Services, and ConfigMaps are namespaced. Nodes, PersistentVolumes, and Namespaces themselves are cluster-scoped.

Resource quotas can limit consumption per namespace. For example, a team can be restricted to a specified CPU, memory, or object-count budget.
