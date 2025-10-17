# Common Issues in Azure Kubernetes Service (AKS) and Solutions

## 1. Node Pool Scaling Issues
**Problem:** Node pools do not scale as expected or new nodes are not provisioned.
**Solution:**
- Check quota limits in Azure subscription.
- Ensure VM SKU is available in the region.
- Use autoscaler logs for troubleshooting.

## 2. Pod Scheduling Failures
**Problem:** Pods remain in Pending state.
**Solution:**
- Check resource requests/limits vs. node capacity.
- Verify taints/tolerations and node selectors.
- Use `kubectl describe pod <pod>` for details.

## 3. Networking and DNS Problems
**Problem:** Services cannot communicate or DNS resolution fails.
**Solution:**
- Ensure correct network plugin (Azure/CNI).
- Check NSG rules and firewall settings.
- Restart CoreDNS pods if needed.

## 4. Persistent Volume Issues
**Problem:** PVCs are stuck in Pending or not bound.
**Solution:**
- Verify storage class configuration.
- Ensure correct permissions for managed identities.
- Check Azure Disk/Files quotas.

## 5. Image Pull Failures
**Problem:** Pods cannot pull images from ACR.
**Solution:**
- Assign `AcrPull` role to AKS managed identity.
- Check ACR firewall and network rules.
- Use `kubectl describe pod` for error details.

## 6. Ingress and SSL Problems
**Problem:** Ingress controller not routing traffic or SSL termination fails.
**Solution:**
- Check ingress controller logs and events.
- Validate DNS and certificate configuration.
- Use Azure Application Gateway Ingress Controller for advanced scenarios.

## 7. RBAC and Permissions Errors
**Problem:** Users or pods lack permissions for resources.
**Solution:**
- Review RBAC roles and bindings.
- Use Azure AD integration for user access.
- Audit with `kubectl auth can-i`.

## 8. Cluster Upgrades and API Deprecation
**Problem:** Upgrades fail or APIs are deprecated.
**Solution:**
- Review upgrade notes and deprecated APIs.
- Test upgrades in a staging environment.
- Use Azure CLI or Portal for safe upgrades.

## 9. Monitoring and Logging Gaps
**Problem:** Missing logs or metrics.
**Solution:**
- Enable Azure Monitor and Container Insights.
- Use Prometheus/Grafana for custom metrics.
- Check log analytics workspace configuration.

## References
- [AKS Troubleshooting Guide](https://learn.microsoft.com/en-us/azure/aks/troubleshooting/)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
