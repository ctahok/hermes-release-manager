---
name: hermes-release-manager
description: "Automate application releases with GitHub integration and deployment."
version: 1.0.0
author: Hermes Release Manager
platforms: [linux, macos, windows]
---

# Hermes Release Manager

Automated application release orchestration with GitHub integration, semantic versioning, and deployment management.

## Overview

Hermes Release Manager automates the entire application release lifecycle:
- Version management (semantic versioning)
- Build automation
- Git operations (commits, tags, releases)
- GitHub repository integration
- Deployment orchestration
- Changelog generation
- Notification and reporting

## Key Features

### 📋 Version Management
- **Semantic versioning** (MAJOR.MINOR.PATCH)
- **Prerelease versions** (alpha, beta, rc)
- **Version bumps** based on commit messages
- **Version history tracking**

### 🔗 GitHub Integration
- **Repository management** (multiple repos)
- **Git operations** (pull, push, branch management)
- **Release creation** (GitHub releases)
- **Asset management** (release artifacts)

### 🚀 Deployment Orchestration
- **Multi-environment deployment** (dev, staging, prod)
- **Blue-green deployment** support
- **Rollback capabilities**
- **Health checks and validation**

## Installation

### Quick Start
```bash
# Load the release manager skill
hermes skills load hermes-release-manager

# Initialize for a repository
hermes release init

# Check current status
hermes release status
```

## Commands

### Version Management
```bash
# Show current version
hermes release version

# Bump version (semantic)
hermes release bump <type>  # major, minor, patch
```

### Build and Release
```bash
# Build the application
hermes release build

# Create release
hermes release create

# Publish release
hermes release publish
```

### Git Operations
```bash
# Sync with remote
hermes release sync
```

## Configuration

### Basic Configuration
```yaml
# ~/.hermes/config.yaml
release:
  enabled: true
  default_repo: "https://github.com/your-username/your-repo"
  token_env: "GH_TOKEN"
  default_branch: "main"
```

## Automation

### Cron Jobs
```bash
# Schedule automated releases
hermes cron create release-weekly --schedule "0 2 * * 0" --command "hermes release deploy prod"

# Daily build and test
hermes cron create build-daily --schedule "0 3 * * *" --command "hermes release build && hermes release test"
```

## License

This project is part of the Hermes Agent ecosystem.

## Support

For help with Hermes Release Manager:
- Check the documentation: `hermes release --help`
- Get support: `hermes release support`