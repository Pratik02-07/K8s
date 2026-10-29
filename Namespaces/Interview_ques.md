
## Interview questions - Namespace

Q1. What is a Kubernetes namespace?

A logical grouping and scope for namespaced resources inside a cluster.

Q2. Why use namespaces?

To organize applications, separate environments or teams, and apply policies such as RBAC and ResourceQuotas.

Q3. What happens when you delete a namespace?

Kubernetes deletes the namespaced resources inside it. Cluster-scoped resources are not automatically deleted just because a namespace is deleted.

Q4. Are namespaces a security boundary?

Not by themselves. Use RBAC, NetworkPolicies, quotas, and other controls for stronger isolation.

Q5. What is the difference between `kubectl get pods` and `kubectl get pods -A`?

The first lists Pods in the current namespace; `-A` lists Pods across all namespaces.

## Quick revision

- Namespace = logical grouping of resources.
- `kubectl get ns` = list namespaces.
- `kubectl create ns dev` = create a namespace.
- `kubectl get pods -n dev` = list Pods in `dev`.
- `kubectl config set-context --current --namespace=dev` = set the default namespace for the current context.
- Namespace deletion removes its namespaced resources.
- Namespaces organize resources; RBAC and NetworkPolicies help enforce access and network isolation.

Next topic: Labels, Selectors and Annotations — these are essential for grouping Pods and connecting them to Services and Deployments.