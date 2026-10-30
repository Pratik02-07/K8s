
## 10. Interview questions - Deployments

Q1. What is a Kubernetes Deployment?

A resource that manages replicated Pods and provides rollout and rollback capabilities.

Q2. What happens when a Pod managed by a Deployment is deleted?

Its ReplicaSet detects that the number of matching Pods is below the desired count and works to create a replacement.

Q3. What is the difference between a Deployment and a ReplicaSet?

A ReplicaSet maintains the desired number of Pods. A Deployment manages ReplicaSets and adds rollout and rollback functionality.

Q4. What is a rolling update?

A strategy that gradually replaces old application Pods with new ones to reduce disruption during an update.

Q5. Does scaling a Deployment change the image version?

No. Scaling changes the desired replica count; changing the image updates the Pod template.

Q6. How do you roll back a Deployment?

Use `kubectl rollout undo deployment/NAME`, provided a suitable previous revision exists.
