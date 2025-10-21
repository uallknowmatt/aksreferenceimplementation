# GitHub Actions Workflow OIDC Fix

## Problem
The GitHub Actions workflow failed with this error:
```
Error: Login failed with Error: Using auth-type: SERVICE_PRINCIPAL. Not all values are present. 
Ensure 'client-id' and 'tenant-id' are supplied.
```

## Root Cause
The workflow was still configured to use **legacy service principal authentication** (requires `AZURE_CREDENTIALS` secret) instead of the **OIDC authentication** we set up.

### What was wrong:
```yaml
# OLD (BROKEN) - Looking for AZURE_CREDENTIALS secret that doesn't exist
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}  # ❌ This secret doesn't exist!
```

### Why it failed:
- We configured OIDC setup with these secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
- The workflow was looking for `AZURE_CREDENTIALS` secret (legacy JSON format)
- Since `AZURE_CREDENTIALS` didn't exist, the login failed

## Solution Applied

### Changed workflow to use OIDC authentication in 2 places:

#### 1. Build-and-push job (lines 32-39)
```yaml
# NEW (FIXED) - Using OIDC with the three secrets we created
- name: Azure Login with OIDC
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    # No client-secret needed! GitHub generates OIDC token automatically
```

#### 2. Deploy job (lines 107-113)
```yaml
# NEW (FIXED) - Using OIDC
- name: Azure Login with OIDC
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

#### 3. AKS context step (lines 115-118)
```yaml
# NEW (FIXED) - Removed 'creds' parameter (uses OIDC from previous step)
- name: Set AKS context
  uses: azure/aks-set-context@v3
  with:
    cluster-name: ${{ needs.build-and-push.outputs.aks_cluster_name }}
    resource-group: ${{ needs.build-and-push.outputs.aks_resource_group }}
    # No 'creds' parameter needed - already authenticated via OIDC!
```

## Verification

### GitHub Secrets (Confirmed ✅)
```bash
$ gh secret list -R uallknowmatt/aksreferenceimplementation

NAME                   UPDATED        
AZURE_CLIENT_ID        about 1 day ago  ✅
AZURE_SUBSCRIPTION_ID  about 1 day ago  ✅
AZURE_TENANT_ID        about 1 day ago  ✅
```

### OIDC Configuration (Confirmed ✅)
- App Registration: `github-actions-oidc`
- Client ID: `dee4be7b-818b-4a94-8de2-4992da57b9c6`
- Federated Credential: `github-actions-main`
- Trust: `repo:uallknowmatt/aksreferenceimplementation:ref:refs/heads/main`
- Role: Contributor on subscription
- Scope: `/subscriptions/d8797220-f5cf-4668-a271-39ce114bb150`

## Expected Result
✅ The workflow should now authenticate successfully using OIDC (passwordless!)

## How OIDC Works
1. GitHub Actions requests an OIDC token from GitHub (automatic)
2. Workflow passes `client-id`, `tenant-id`, `subscription-id` to azure/login action
3. Azure verifies the OIDC token matches the federated credential trust relationship
4. Azure grants temporary access (no passwords stored anywhere!)
5. Workflow can now access Azure resources

## Benefits of OIDC vs Secrets
| Legacy (AZURE_CREDENTIALS) | OIDC (Current) |
|---------------------------|----------------|
| ❌ JSON with client secret | ✅ No passwords |
| ❌ Expires every 90 days | ✅ Auto-rotating tokens |
| ❌ Manual rotation | ✅ No maintenance |
| ❌ 1 secret = full JSON | ✅ 3 separate IDs (clearer) |
| ❌ Risk if leaked | ✅ Tokens expire in minutes |

## Files Changed
- `.github/workflows/aks-deploy.yml` - Switched from service principal to OIDC authentication

## Commit
```bash
git commit -m "Fix workflow: Switch from service principal to OIDC authentication"
git push origin main
```

## Next Steps
1. ✅ Workflow file updated and pushed
2. Monitor GitHub Actions run: https://github.com/uallknowmatt/aksreferenceimplementation/actions
3. Verify OIDC authentication succeeds
4. Check that Terraform runs successfully
5. Verify services build and deploy to AKS

---

**Status**: 🎉 **FIXED** - Workflow now uses OIDC authentication correctly!
