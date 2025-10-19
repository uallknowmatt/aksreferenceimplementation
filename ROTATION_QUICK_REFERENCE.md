# Quick Reference: Automated Credential Rotation

## ✅ What's Automated

**Your Azure service principal credentials now rotate automatically with ZERO human interaction!**

## 🔄 How It Works

1. **Daily Check** - GitHub Actions runs at 2 AM UTC every day
2. **Smart Detection** - Checks if credentials expire in ≤ 10 days
3. **Automatic Rotation** - Creates new password while keeping old one valid
4. **Zero Downtime** - Overlapping validity ensures continuous operation
5. **Self-Update** - GitHub secret updates automatically

## 📊 Current Status

- **Rotation Schedule**: Daily at 2 AM UTC
- **Rotation Trigger**: 10 days before expiration
- **Password Validity**: 1 year
- **Grace Period**: 24 hours (old + new both valid)
- **Human Interaction**: **ZERO** 🎉

## 🔍 Monitor Rotation

View workflow runs:
```
https://github.com/uallknowmatt/aksreferenceimplementation/actions/workflows/rotate-credentials.yml
```

## 🧪 Test Rotation

Manually trigger rotation to test:

1. Go to Actions → Rotate Azure Credentials
2. Click "Run workflow"
3. Enable "force_rotation"
4. Click "Run workflow"

## 📖 Full Documentation

See **AUTOMATED_CREDENTIAL_ROTATION.md** for complete details.

## 🎯 Key Benefits

✅ Never expires (auto-rotates 10 days early)  
✅ Zero downtime (overlapping validity)  
✅ No human needed (fully automated)  
✅ Self-healing (verifies new credentials)  
✅ Secure (no credentials in logs)  

**Set it and forget it!** 🚀
