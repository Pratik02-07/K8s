# Kubernetes: ReplicaSet vs Deployment vs StatefulSet

![Kubernetes ReplicaSet, Deployment and StatefulSet
comparison](kubernetes-workload-comparison.svg)

## 1. Overview

  -----------------------------------------------------------------------
  Resource                What it does            Typical use
  ----------------------- ----------------------- -----------------------
  **ReplicaSet**          Maintains a desired     Low-level replica
                          number of matching      management; usually
                          Pods.                   managed by a
                                                  Deployment.

  **Deployment**          Manages ReplicaSets and Stateless web
                          provides rollout,       applications, APIs and
                          rollback and scaling    microservices.
                          capabilities.           

  **StatefulSet**         Manages Pods with       Databases and other
                          stable identities and   stateful, clustered
                          persistent storage      applications.
                          associations.           
  -----------------------------------------------------------------------

## 2. ReplicaSet

A **ReplicaSet** ensures that the specified number of matching Pods are
running. If a managed Pod is deleted or becomes unavailable, the
ReplicaSet works to create a replacement.

### Example YAML

``` yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
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

### Commands

``` bash
kubectl apply -f replicaset.yaml
kubectl get replicasets
kubectl get pods
kubectl describe rs nginx-rs
kubectl scale rs nginx-rs --replicas=5
kubectl delete rs nginx-rs
```

**Remember:** In normal application deployments, you generally create a
Deployment rather than a ReplicaSet directly.

## 3. Deployment

A **Deployment** manages ReplicaSets and provides declarative updates
for Pods. It is the standard choice for most stateless applications.

### Main features

-   Maintains the desired number of replicas through ReplicaSets.
-   Supports scaling.
-   Supports rolling updates.
-   Keeps rollout revision history and supports rollback.
-   Reconciles the desired state with the actual state.

### Example YAML

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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

### Commands

``` bash
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl get replicasets
kubectl get pods

# Scale
kubectl scale deployment nginx-deployment --replicas=5

# Update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.28

# Monitor rollout
kubectl rollout status deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment

# Roll back to a previous revision
kubectl rollout undo deployment/nginx-deployment
```

A rollback restores a previous Pod template revision. It does not
automatically reverse external database migrations or changes outside
Kubernetes.

## 4. StatefulSet

A **StatefulSet** manages stateful applications that need stable Pod
identities and persistent storage associations.

For example, a three-replica StatefulSet creates predictable Pod names:

``` text
mysql-0
mysql-1
mysql-2
```

If `mysql-1` is replaced, the replacement retains the `mysql-1`
identity. Its associated PersistentVolumeClaim can be reused.

### Main features

-   Stable ordinal Pod names.
-   Stable network identity, commonly provided through a headless
    Service.
-   PersistentVolumeClaim templates can create one claim per Pod.
-   Ordered creation and termination by default.
-   Controlled updates and scaling.

### Example YAML

This is an illustrative Nginx StatefulSet demonstrating stable
identities and per-Pod storage claims. It is not a production database
configuration.

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
    - name: web
      port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx
spec:
  serviceName: nginx-headless
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
          volumeMounts:
            - name: nginx-storage
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: nginx-storage
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

The cluster needs a suitable StorageClass or matching PersistentVolumes
for the PVCs to bind.

### Commands

``` bash
kubectl apply -f statefulset.yaml

kubectl get statefulsets
kubectl get pods
kubectl get pvc
kubectl get svc

# Scale
kubectl scale statefulset nginx --replicas=4

# Inspect
kubectl describe statefulset nginx
```

Deleting a StatefulSet does **not** automatically delete its associated
PVCs. Review persistent storage separately before deleting it.

## 5. Main differences

  -------------------------------------------------------------------------
  Feature           ReplicaSet         Deployment        StatefulSet
  ----------------- ------------------ ----------------- ------------------
  Main purpose      Maintain Pod       Manage            Manage stateful
                    replicas           application       workloads
                                       releases          

  Pod identity      Interchangeable    Interchangeable   Stable ordinal
                                                         identity

  Predictable Pod   No                 No                Yes
  names                                                  

  Scaling           Yes                Yes               Yes

  Rolling updates   No                 Yes               Yes, using
                    Deployment-style                     StatefulSet update
                    rollout management                   policies

  Rollback history  No                 Yes               No
                    Deployment-style                     Deployment-style
                    history                              rollout history

  Persistent        Can use volumes    Can use volumes   Supports
  storage                                                per-replica PVC
                                                         templates

  Typical use       Low-level replica  Stateless         Databases and
                    management         applications      stateful clusters
  -------------------------------------------------------------------------

## 6. Real-world examples

  -----------------------------------------------------------------------
  Application             Recommended resource    Why
  ----------------------- ----------------------- -----------------------
  Nginx frontend          Deployment              Replicas are
                                                  interchangeable.

  FastAPI backend         Deployment              Stateless API replicas
                                                  can be scaled
                                                  independently.

  Node.js microservice    Deployment              Supports rolling
                                                  releases and scaling.

  Database replicas       StatefulSet, when       Stable identity and
                          stable identity/storage persistent claims.
                          is needed               

  Redis cluster           Depends on              Stateful members may
                          architecture; often     need stable identity
                          StatefulSet             and storage.
  -----------------------------------------------------------------------

A StatefulSet does not automatically make a database highly available.
Database replication, leader election, consistency and failover still
require application-level configuration or an operator.

## 7. Interview questions

**Q1. Why use Deployment instead of ReplicaSet?**

A Deployment manages ReplicaSets and adds rolling updates, rollback and
rollout history.

**Q2. What happens when a Deployment-managed Pod is deleted?**

The ReplicaSet managed by the Deployment detects that the number of
matching Pods is below the desired count and creates a replacement.

**Q3. Can a Deployment run a stateful application?**

Technically yes, but if the application requires stable Pod identity,
ordered operations and per-replica storage, StatefulSet is usually more
appropriate.

**Q4. What happens when a StatefulSet Pod is deleted?**

The StatefulSet controller recreates it with the same ordinal identity.
Its existing PVC can be reused.

**Q5. Does StatefulSet automatically provide database high
availability?**

No. It provides stable identities, ordering and storage associations.
Database-level replication and failover must be configured separately.

**Q6. Can a ReplicaSet perform a Deployment-style rolling update?**

No. A ReplicaSet maintains replicas. Deployment coordinates updates by
managing ReplicaSets.

## 8. Quick revision

-   **ReplicaSet:** Maintains the desired number of Pods.
-   **Deployment:** Manages ReplicaSets, scaling, rolling updates and
    rollbacks.
-   **StatefulSet:** Manages stable Pod identities, ordered operations
    and persistent storage associations.

**Practical recommendation:** Learn Deployments and ReplicaSets first.
Understand StatefulSets well enough to explain stable identities,
persistent claims, ordering and database use cases.

## 9. Suggested hands-on practice

1.  Create a Deployment with three Nginx replicas.
2.  Delete one Pod and observe self-healing.
3.  Scale the Deployment to five replicas.
4.  Update its image and monitor the rollout.
5.  Roll back to the previous revision.
6.  Create a StatefulSet and inspect its predictable Pod names and PVCs.
7.  Delete a StatefulSet and inspect what happens to its PVCs.

### Official documentation

-   [ReplicaSets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
-   [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
-   [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
