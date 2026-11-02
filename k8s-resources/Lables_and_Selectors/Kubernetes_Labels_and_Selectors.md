# Kubernetes Labels and Selectors

![Kubernetes Labels and Selectors
diagram](kubernetes-labels-selectors.svg)

## 1. What are Labels?

**Labels are key-value pairs attached to Kubernetes objects** to
identify, organize, and categorize resources such as Pods, Deployments,
Services, and Nodes.

Example:

``` yaml
metadata:
  labels:
    app: ecommerce
    environment: production
    tier: backend
```

Here, `app`, `environment`, and `tier` are label keys; `ecommerce`,
`production`, and `backend` are their values.

### Why labels are useful

-   Group resources by application or team.
-   Identify frontend, backend, and database components.
-   Separate dev, UAT, and production workloads.
-   Allow Services and workload controllers to select Pods.
-   Filter resources during troubleshooting and operations.

## 2. What are Selectors?

**Selectors identify Kubernetes objects by matching their labels.**

Remember:

-   **Label:** identifies or describes a resource.
-   **Selector:** finds resources by matching labels.

Example:

``` bash
kubectl get pods -l tier=backend
```

This returns Pods with the label `tier=backend`.

### Example Pod labels

  -----------------------------------------------------------------------
  Pod                                 Labels
  ----------------------------------- -----------------------------------
  `frontend-pod`                      `app=ecommerce`, `tier=frontend`,
                                      `environment=dev`

  `backend-pod-1`                     `app=ecommerce`, `tier=backend`,
                                      `environment=dev`

  `backend-pod-2`                     `app=ecommerce`, `tier=backend`,
                                      `environment=prod`
  -----------------------------------------------------------------------

## 3. Selector types

### A. Equality-based selectors

Equality-based selectors support equality and inequality matching.

  Operator      Meaning
  ------------- ------------------------------------------------
  `=` or `==`   Label value equals the specified value
  `!=`          Label value does not equal the specified value

Examples:

``` bash
# Select dev Pods
kubectl get pods -l environment=dev

# Select backend Pods
kubectl get pods -l tier==backend

# Select Pods whose environment is not prod
kubectl get pods -l environment!=prod

# Multiple requirements: all must match (AND)
kubectl get pods -l app=ecommerce,tier=backend
```

### B. Set-based selectors

Set-based selectors support more flexible matching.

  Operator   Meaning
  ---------- --------------------------------------------
  `in`       Value must be one of the listed values
  `notin`    Value must not be one of the listed values
  `key`      Label key must exist
  `!key`     Label key must not exist

Examples:

``` bash
# Select frontend OR backend
kubectl get pods -l 'tier in (frontend,backend)'

# Exclude production
kubectl get pods -l 'environment notin (prod)'

# Select Pods where the tier key exists
kubectl get pods -l 'tier'

# Select Pods where the tier key does not exist
kubectl get pods -l '!tier'
```

**Important:** Multiple selector requirements are combined using logical
AND. A comma does not mean OR.

## 4. Create Pods with labels

Create `pods.yaml`:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend-pod
  labels:
    app: ecommerce
    tier: frontend
    environment: dev
spec:
  containers:
    - name: nginx
      image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
  labels:
    app: ecommerce
    tier: backend
    environment: dev
spec:
  containers:
    - name: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: payment-pod
  labels:
    app: ecommerce
    tier: payment
    environment: prod
spec:
  containers:
    - name: nginx
```

Apply and inspect:

``` bash
kubectl apply -f pods.yaml
kubectl get pods --show-labels
```

Try selectors:

``` bash
kubectl get pods -l tier=backend
kubectl get pods -l environment=prod
kubectl get pods -l app=ecommerce,environment=dev
kubectl get pods -l 'tier in (frontend,backend)'
```

## 5. Add, update, and remove labels

``` bash
# Add a label
kubectl label pod frontend-pod team=devops

# Update an existing label
kubectl label pod frontend-pod environment=uat --overwrite

# Remove a label (the trailing hyphen is important)
kubectl label pod frontend-pod team-
```

Verify:

``` bash
kubectl get pod frontend-pod --show-labels
```

## 6. How Services use selectors

A Service uses a label selector to identify matching Pods and route
traffic to eligible endpoints.

Example:

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: ecommerce
    tier: backend
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

The Service selects Pods that match **both** labels:

-   `app=ecommerce`
-   `tier=backend`

If a Pod does not have the required labels, it is not selected by this
Service. Kubernetes publishes eligible backends through EndpointSlices.

Inspect:

``` bash
kubectl get service backend-service
kubectl get endpointslices
```

## 7. How Deployments use selectors

A Deployment selector identifies the Pods that its ReplicaSet manages.
The selector must match the labels in the Pod template.

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: nginx
          image: nginx
```

The following two values must match:

``` yaml
selector:
  matchLabels:
    app: backend
```

``` yaml
template:
  metadata:
    labels:
      app: backend
```

Deployment selectors are immutable after creation in `apps/v1`; choose
them carefully.

## 8. Labels vs Annotations

  -----------------------------------------------------------------------
  Labels                              Annotations
  ----------------------------------- -----------------------------------
  Identify and group objects          Store additional descriptive
                                      metadata

  Used by selectors                   Not used by label selectors

  Useful for Services and controllers Useful for tools, integrations, and
                                      automation

  Intended for identification and     Can store larger or less
  querying                            query-oriented metadata
  -----------------------------------------------------------------------

Label example:

``` yaml
labels:
  app: ecommerce
  environment: production
```

Annotation example:

``` yaml
annotations:
  description: "Production backend application"
  owner: "DevOps Team"
```

**Remember:** Labels are for selection; annotations are for additional
information.

## 9. Important kubectl commands

  Command                                   Purpose
  ----------------------------------------- --------------------------------
  `kubectl get pods --show-labels`          Show Pods and their labels
  `kubectl get pods -l app=backend`         Select Pods by label
  `kubectl get pods -L app,tier`            Display selected label columns
  `kubectl describe pod POD`                Inspect Pod details
  `kubectl label pod POD team=devops`       Add a label
  `kubectl label pod POD team-`             Remove a label
  `kubectl get deployments --show-labels`   Show Deployment labels

## 10. Interview questions

**Q1. What are Labels in Kubernetes?**

Key-value metadata attached to Kubernetes objects for identification,
grouping, and selection.

**Q2. What are Selectors?**

Queries that identify objects by matching their labels.

**Q3. What is the difference between equality-based and set-based
selectors?**

Equality-based selectors match equality or inequality. Set-based
selectors support `in`, `notin`, and key-existence requirements.

**Q4. How does a Service find its Pods?**

It uses a label selector to identify matching Pods and publishes
eligible backends through EndpointSlices.

**Q5. Can a Pod have multiple labels?**

Yes. A Pod can have labels such as `app`, `environment`, `team`, and
`tier`.

**Q6. How are multiple selector requirements combined?**

They are combined with logical AND.

**Q7. What is the difference between Labels and Annotations?**

Labels are used for grouping and selection. Annotations store additional
metadata and are not used by label selectors.

## 11. Quick revision

-   **Label:** key-value metadata attached to a resource.
-   **Selector:** finds resources using labels.
-   **`=` / `==`:** equality.
-   **`!=`:** inequality.
-   **`in`:** match one of a set of values.
-   **`notin`:** exclude a set of values.
-   **`key`:** key exists.
-   **`!key`:** key does not exist.
-   **Service selector:** selects backend Pods.
-   **Deployment selector:** identifies Pods managed by its ReplicaSet.
-   **Annotation:** additional metadata, not a selector field.

Most important command:

``` bash
kubectl get pods -l app=backend
```

## 12. Hands-on practice

1.  Create the three Pods from `pods.yaml`.
2.  List them with `kubectl get pods --show-labels`.
3.  Select only backend Pods.
4.  Select dev Pods.
5.  Try a set-based selector.
6.  Add, update, and remove a label.
7.  Create a Service that selects backend Pods.
8.  Inspect the Service's EndpointSlices.
9.  Delete the lab resources:

``` bash
kubectl delete -f pods.yaml
```

### Official documentation

-   [Kubernetes Labels and
    Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
-   [Service
    selectors](https://kubernetes.io/docs/concepts/services-networking/service/)
-   [Deployment
    selectors](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
