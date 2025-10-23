# VS Code Configuration

This folder contains VS Code workspace settings for the Bank Account Opening System project.

---

## Files

### `settings.json`
**Purpose:** Workspace-specific settings that override user settings

**Key Configurations:**

#### 1. **Git Bash as Default Terminal**
```json
"terminal.integrated.defaultProfile.windows": "Git Bash"
```
- **Why:** Shell scripts (`.sh`), Azure CLI, and kubectl work best in Bash
- **Alternatives:** PowerShell and Command Prompt still available in dropdown
- **Path:** `C:\Program Files\Git\bin\bash.exe`

#### 2. **File Associations**
```json
"files.associations": {
    "*.sh": "shellscript",
    "*.tf": "terraform",
    "*.tfvars": "terraform",
    "Dockerfile*": "dockerfile"
}
```
- Proper syntax highlighting for all file types
- IntelliSense support for Terraform and YAML

#### 3. **Auto-Formatting**
```json
"[shellscript]": {
    "editor.formatOnSave": true
},
"[yaml]": {
    "editor.formatOnSave": true
},
"[terraform]": {
    "editor.formatOnSave": true
}
```
- Automatically formats files on save
- Consistent code style across the project

#### 4. **ShellCheck Linting**
```json
"shellcheck.enable": true,
"shellcheck.run": "onType"
```
- Real-time shell script validation
- Catches common scripting errors
- Requires ShellCheck extension (recommended)

#### 5. **Editor Preferences**
```json
"files.eol": "\n",
"files.trimTrailingWhitespace": true,
"files.insertFinalNewline": true
```
- Unix-style line endings (LF, not CRLF)
- Clean code formatting
- Git-friendly file handling

---

### `extensions.json`
**Purpose:** Recommended VS Code extensions for this project

When you open the project, VS Code will prompt you to install missing recommended extensions.

**Categories:**

#### Shell & Terminal
- `timonwong.shellcheck` - Shell script linting
- `foxundermoon.shell-format` - Shell script formatter
- `mads-hartmann.bash-ide-vscode` - Bash IntelliSense

#### Azure & Cloud
- `ms-azuretools.vscode-azureterraform` - Terraform for Azure
- `ms-azuretools.vscode-docker` - Docker support
- `ms-kubernetes-tools.vscode-kubernetes-tools` - Kubernetes management
- `ms-vscode.azurecli` - Azure CLI tools

#### Infrastructure as Code
- `hashicorp.terraform` - Terraform syntax and validation

#### Java & Spring Boot
- `vscjava.vscode-java-pack` - Complete Java development
- `pivotal.vscode-spring-boot` - Spring Boot tools

#### JavaScript & React
- `esbenp.prettier-vscode` - Code formatter
- `dsznajder.es7-react-js-snippets` - React snippets

#### Git & GitHub
- `github.vscode-github-actions` - GitHub Actions workflows
- `eamodio.gitlens` - Advanced Git features

#### Documentation
- `yzhang.markdown-all-in-one` - Markdown editing
- `bierner.markdown-mermaid` - Diagram support

**To Install All:**
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type: "Extensions: Show Recommended Extensions"
3. Click "Install All Workspace Recommendations"

---

### `tasks.json`
**Purpose:** Pre-configured tasks for common development operations

**Access Tasks:**
- Press `Ctrl+Shift+B` for build tasks
- Press `Ctrl+Shift+P` → Type "Tasks: Run Task" for all tasks

**Available Tasks:**

#### Azure CLI Tasks
- **Azure: Login** - Sign in to Azure
- **Azure: Check Infrastructure Status** - View AKS and PostgreSQL status
- **Kubectl: Get All Pods** - List Kubernetes pods
- **Kubectl: Get All Services** - List Kubernetes services

#### Local Development Tasks
- **Local: Start Docker Compose** - Start all services locally
- **Local: Stop Docker Compose** - Stop all services
- **Local: Docker Compose Logs** - View logs (tail -f)

#### Build Tasks
- **Maven: Clean Install (All Services)** - Build entire project (default build)
- **Maven: Build Customer Service** - Build single service
- **Maven: Build Document Service**
- **Maven: Build Account Service**
- **Maven: Build Notification Service**

#### Frontend Tasks
- **Frontend: Install Dependencies** - `npm install`
- **Frontend: Start Dev Server** - `npm start` (http://localhost:3000)
- **Frontend: Build Production** - `npm run build`

#### Terraform Tasks
- **Terraform: Init (Dev)** - Initialize Terraform backend
- **Terraform: Plan (Dev)** - Preview infrastructure changes
- **Terraform: Format** - Format all `.tf` files
- **Terraform: Validate** - Validate Terraform configuration

#### Testing Tasks
- **Test: Run Health Checks** - Run automated deployment tests

#### Git Tasks
- **Git: View Status** - `git status`
- **Git: Pull Latest** - `git pull`

**Example Usage:**
```
1. Press Ctrl+Shift+P
2. Type "Tasks: Run Task"
3. Select "Azure: Check Infrastructure Status"
4. View results in integrated terminal
```

---

## Terminal Configuration

### Default Terminal: Git Bash

**Why Git Bash?**
- ✅ **Shell Scripts** - Native `.sh` script execution
- ✅ **Azure CLI** - Works seamlessly with `az` commands
- ✅ **kubectl** - Kubernetes CLI integration
- ✅ **Terraform** - Infrastructure as Code commands
- ✅ **Unix Tools** - grep, awk, sed, etc.
- ✅ **Git Integration** - Best Git experience

**Alternative Terminals:**
- **PowerShell** - Available in terminal dropdown (for educational scripts)
- **Command Prompt** - Available in terminal dropdown

**Switching Terminals:**
1. Click the `+` dropdown in terminal panel
2. Select desired terminal type
3. Or use Command Palette: "Terminal: Select Default Profile"

---

## First Time Setup

When you first open this project in VS Code:

### 1. Install Recommended Extensions
```
1. VS Code will show a notification: "This workspace has extension recommendations"
2. Click "Install All"
3. Wait for extensions to install
4. Reload VS Code if prompted
```

### 2. Verify Git Bash Installation
```bash
# Check if Git Bash is installed
ls "C:\Program Files\Git\bin\bash.exe"

# If not found, install Git for Windows:
# https://git-scm.com/download/win
```

### 3. Install ShellCheck (Optional but Recommended)
```bash
# Windows (via Chocolatey)
choco install shellcheck

# Or download from:
# https://github.com/koalaman/shellcheck#installing
```

### 4. Open Integrated Terminal
```
1. Press Ctrl+` (backtick) to open terminal
2. Should open Git Bash automatically
3. Try running: az --version
```

---

## Customization

### Change Default Terminal

Edit `.vscode/settings.json`:

```json
// Use PowerShell instead
"terminal.integrated.defaultProfile.windows": "PowerShell"

// Or Command Prompt
"terminal.integrated.defaultProfile.windows": "Command Prompt"
```

### Disable Auto-Formatting

Edit `.vscode/settings.json`:

```json
"[shellscript]": {
    "editor.formatOnSave": false  // Change to false
}
```

### Add Custom Tasks

Edit `.vscode/tasks.json`:

```json
{
    "label": "My Custom Task",
    "type": "shell",
    "command": "echo 'Hello World'",
    "problemMatcher": [],
    "group": "none"
}
```

---

## Troubleshooting

### Git Bash Not Found

**Error:** `The terminal process failed to launch: Path to shell executable "C:\Program Files\Git\bin\bash.exe" does not exist.`

**Solution:**
1. Install Git for Windows: https://git-scm.com/download/win
2. Or update path in `settings.json` to your Git Bash location

### Extensions Not Working

**Issue:** Extensions don't activate or show errors

**Solution:**
1. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
2. Check extension logs: `Ctrl+Shift+P` → "Developer: Show Logs"
3. Update extensions: `Ctrl+Shift+P` → "Extensions: Check for Extension Updates"

### Tasks Not Running

**Issue:** Tasks fail with "command not found"

**Solution:**
1. Ensure Git Bash is the active terminal
2. Check PATH includes Azure CLI, kubectl, terraform
3. Restart VS Code after installing tools

### Line Ending Issues

**Issue:** Git shows all files as modified (CRLF vs LF)

**Solution:**
Already configured in `settings.json`:
```json
"files.eol": "\n"  // Forces Unix line endings (LF)
```

If issue persists:
```bash
# Normalize line endings
git add --renormalize .
git commit -m "Normalize line endings"
```

---

## Benefits of This Configuration

✅ **Consistent Environment** - Everyone uses same terminal and tools  
✅ **Auto-Formatting** - Code stays clean automatically  
✅ **Script Validation** - Catch errors before running  
✅ **Quick Tasks** - Common operations one click away  
✅ **Extension Recommendations** - New team members get right tools  
✅ **Git Bash Default** - Best compatibility with scripts and Azure CLI  
✅ **Azure/Kubernetes Integration** - Seamless cloud development  

---

## Related Documentation

- **[../scripts/educational/README.md](../scripts/educational/README.md)** - Script usage guide
- **[../docs/DEPLOYMENT_GUIDE.md](../docs/DEPLOYMENT_GUIDE.md)** - Deployment procedures
- **[../README.md](../README.md)** - Project overview

---

**Questions?** These settings are workspace-specific and won't affect your global VS Code configuration.
