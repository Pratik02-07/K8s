
## Interview questions - kubectl

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
