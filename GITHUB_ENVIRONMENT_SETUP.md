# GitHub Environment Setup for Production Approval

This guide explains how to set up the GitHub environment for manual production deployment approval.

## Overview

The deployment workflow uses a GitHub Environment called `production-approval` to gate production deployments. This requires manual approval before proceeding with production.

## Setup Steps

### 1. Create the Production Approval Environment

1. Go to your GitHub repository: https://github.com/uallknowmatt/aksreferenceimplementation
2. Click on **Settings** tab
3. In the left sidebar, click **Environments**
4. Click **New environment**
5. Enter name: `production-approval`
6. Click **Configure environment**

### 2. Configure Required Reviewers

1. In the environment configuration page, check **Required reviewers**
2. Click **Add reviewers**
3. Search for and select the users who should approve production deployments (e.g., yourself, team leads)
4. Click **Save protection rules**

### 3. Optional: Configure Deployment Branches

1. Scroll to **Deployment branches**
2. Select **Selected branches**
3. Click **Add deployment branch rule**
4. Enter: `main`
5. Click **Add rule**

This ensures production can only be deployed from the main branch.

### 4. Optional: Add Wait Timer

1. In the environment configuration, find **Wait timer**
2. Enter a wait time (e.g., 5 minutes)
3. This adds an additional delay before deployment can proceed

## How It Works

### Workflow Flow

1. **Push to main** → Dev deployment starts automatically
2. **Dev completes** → Workflow pauses at "UAT Test Complete" job
3. **Manual approval required** → Designated reviewers get notification
4. **Reviewer approves** → Production deployment begins
5. **Production completes** → All services deployed

### Approval Process

When the workflow reaches the `uat-test-complete` job:

1. **Notification**: Reviewers receive an email and GitHub notification
2. **Review**: Reviewers can view:
   - Dev deployment results
   - Changes in the commit
   - Test results (if any)
3. **Approve or Reject**:
   - **Approve**: Production deployment proceeds
   - **Reject**: Workflow stops, no production deployment

### Where to Approve

**Method 1: GitHub UI**
1. Go to **Actions** tab
2. Click on the running workflow
3. You'll see a yellow banner: "This workflow is waiting for approval"
4. Click **Review deployments**
5. Select `production-approval`
6. Add optional comment
7. Click **Approve and deploy** or **Reject**

**Method 2: Email Notification**
1. Open the notification email
2. Click the **Review deployment** link
3. Follow same approval steps as above

## Testing the Approval Flow

To test that the approval flow works:

1. Make a small change to the code (e.g., update README.md)
2. Commit and push to main
3. Go to Actions tab and watch the workflow
4. Observe:
   - Dev deployment completes automatically
   - Workflow pauses at "UAT Test Complete"
   - Orange icon appears requesting approval
5. Click **Review deployments**
6. Approve the deployment
7. Watch production deployment proceed

## Troubleshooting

### Issue: No approval required

**Symptoms**: Production deploys automatically without waiting

**Solution**:
- Verify the environment name is exactly `production-approval`
- Check that required reviewers are configured
- Ensure the workflow file uses `environment: name: production-approval`

### Issue: Can't find review button

**Symptoms**: Workflow is paused but no review button visible

**Solution**:
- Ensure you're added as a required reviewer
- Try refreshing the page
- Check your GitHub notifications
- Look for yellow banner at top of workflow run

### Issue: Wrong person can approve

**Symptoms**: Anyone can approve production deployment

**Solution**:
- Go to Settings → Environments → production-approval
- Check the Required reviewers list
- Remove unauthorized users
- Add only designated approvers

## Security Best Practices

1. **Limit Reviewers**: Only add trusted team members as required reviewers
2. **Use Multiple Reviewers**: Require 2+ approvals for production
3. **Branch Protection**: Restrict who can push to main branch
4. **Review Changes**: Always review the diff before approving
5. **Deployment Windows**: Use wait timers to enforce change windows

## Alternative: Using GitHub Issues for Approval

For more formal approval processes, you can integrate with GitHub Issues:

1. Create an issue when deployment is ready
2. Team reviews the issue
3. Approve via issue comment
4. Workflow checks issue status before deploying

This is more complex but provides better audit trails.

## Rollback Process

If production deployment fails or needs rollback:

1. **Immediate**: Use kubectl to rollback
   ```bash
   kubectl rollout undo deployment/<service-name>
   ```

2. **Complete Rollback**: Revert commit and push
   ```bash
   git revert HEAD
   git push origin main
   ```
   This triggers dev deployment, then requires approval for prod rollback

## Monitoring Approvals

To audit who approved what:

1. Go to **Actions** tab
2. Click on any workflow run
3. Scroll to the approval job
4. Click **Show more details**
5. View who approved and when

All approvals are logged and auditable.

## Additional Resources

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Required Reviewers](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#required-reviewers)
- [Deployment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#deployment-protection-rules)

---

**Next Steps**: After setting up the environment, test the workflow with a small change to verify approval gates work correctly.
