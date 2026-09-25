# Hermes Release Manager

Automated application release orchestration with GitHub integration, semantic versioning, and deployment management.

## Overview

Hermes Release Manager automates the entire application release lifecycle, combining intelligent version management, build automation, GitHub integration, and deployment orchestration.

## Quick Start

### 1. Installation
```bash
# Load the release manager skill
hermes skills load hermes-release-manager

# Initialize for your repository
hermes release init
```

### 2. Configuration
```bash
# Set up GitHub integration
hermes release config repo https://github.com/your-username/your-repo
hermes release config token --env "GH_TOKEN"

# Configure default branch
hermes release config default-branch main
```

### 3. Basic Commands
```bash
# Check current version
hermes release version

# Bump version (semantic)
hermes release bump minor
hermes release bump patch
hermes release bump major

# Build the application
hermes release build

# Create release (draft)
hermes release create

# Publish release
hermes release publish

# Deploy to environment
hermes release deploy dev
hermes release deploy staging
hermes release deploy prod
```

### 4. Automation Setup
```bash
# Schedule automated releases
hermes cron create release-weekly --schedule "0 2 * * 0" --command "hermes release deploy prod"

# Daily build and test
hermes cron create build-daily --schedule "0 3 * * *" --command "hermes release build && hermes release test"
```

## Features

### 📋 Version Management
- **Semantic versioning** following MAJOR.MINOR.PATCH convention
- **Automatic version bumping** based on commit messages
- **Prerelease support** for alpha, beta, and rc versions
- **Version history tracking** with git tags

### 🔗 GitHub Integration
- **Repository management** for multiple GitHub repositories
- **Git operations** (pull, push, branch management)
- **GitHub releases** with automatic notes generation
- **Asset management** for release artifacts

### 🚀 Deployment Orchestration
- **Multi-environment support** (dev, staging, production)
- **Blue-green deployment** capabilities
- **Rollback functionality**
- **Health checks and validation**

### 📊 Monitoring and Reporting
- **Release and deployment management**
- **Version control**
- **Build automation**
- **Multi-environment deployment**

## Configuration

### Basic Configuration
```yaml
# ~/.hermes/config.yaml
release:
  enabled: true
  default_repo: "https://github.com/your-username/your-repo"
  token_env: "GH_TOKEN"
  default_branch: "main"
  protected_branches: ["main", "production"]
```

## Automation

### Scheduled Releases
```bash
# Weekly release pipeline
hermes cron create release-weekly --schedule "0 2 * * 0" --command "hermes release create && hermes release deploy prod"

# Daily build and test
hermes cron create build-daily --schedule "0 3 * * *" --command "hermes release build && hermes release test"
```

### Webhook Integration
```bash
# Set up webhook for automated releases
hermes release setup-webhook --event push --command "hermes release deploy staging"
hermes release setup-webhook --event pull_request --command "hermes release test"
```

## Best Practices

### Version Management
- Use semantic versioning consistently
- Document breaking changes in commit messages
- Use prerelease versions for testing
- Maintain clear version history

### Build Process
- Automate builds with version detection
- Run comprehensive tests before release
- Validate artifacts
- Create proper documentation

### Deployment
- Use feature flags for gradual rollouts
- Implement blue-green deployment strategies
- Have rollback plans ready
- Monitor deployment health

### Communication
- Notify stakeholders before major releases
- Document release notes
- Update documentation
- Communicate deployment status

## Troubleshooting

### Common Issues

#### "Repository not found"
```bash
# Check repository URL
hermes release config repo

# Verify authentication
hermes release test-auth
```

#### "Build failed"
```bash
# Check build logs
hermes release build --verbose

# View build configuration
hermes release config build
```

#### "Release publish failed"
```bash
# Check GitHub token
hermes release config token

# Test GitHub authentication
gh auth status
```

### Getting Help
```bash
# Get help for specific commands
hermes release <command> --help

# Get support
hermes release support
```

## License

This project is part of the Hermes Agent ecosystem. Use responsibly and follow your organization's release management policies.

## Support

For help with Hermes Release Manager:
- Check the documentation: `hermes release --help`
- Get support: `hermes release support`
