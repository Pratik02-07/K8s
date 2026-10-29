
## Interview questions - Pods

Q1. What is a Pod in Kubernetes?

The smallest deployable unit in Kubernetes, containing one or more containers that share networking and can share storage.

Q2. Can a Pod contain multiple containers?

Yes. This is useful for tightly coupled containers, such as an application and a sidecar.

Q3. Do containers in the same Pod share an IP address?

Yes. They share the Pod's network namespace and IP address, so they can communicate using `localhost`. They must avoid port conflicts within that shared network namespace.

Q4. Does Kubernetes automatically recreate a deleted standalone Pod?

No. A standalone Pod has no controller to recreate it. A Deployment or another appropriate controller can maintain the desired workload.

Q5. Why shouldn't we use Pod IP addresses as permanent endpoints?

Pods can be replaced and receive new IP addresses. Services provide stable access to selected Pods.

Q6. What is the difference between a Pod's `containerPort` and a Service port?

`containerPort` documents a port in the container specification. A Service port defines the port clients use to access the Service, which forwards traffic to its configured target port.
