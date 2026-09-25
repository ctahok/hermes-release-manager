#!/bin/bash

# Hermes Automated Release Script
# Usage: ./release.sh [command] [options]

# Configuration
CONFIG_FILE="~/.hermes/config.yaml"
RELEASE_DIR="$HOME/.hermes/releases"
GIT_REPO="${HERMES_RELEASE_REPO:-$(grep -A1 "release:" $CONFIG_FILE | grep "default_repo:" | cut -d'"' -f2)}"
GH_TOKEN="${HERMES_GH_TOKEN:-$GH_TOKEN}"
DEFAULT_BRANCH="${HERMES_DEFAULT_BRANCH:-$(grep -A1 "release:" $CONFIG_FILE | grep "default_branch:" | cut -d'"' -f2)}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <command> [options]"
    echo "Commands: init, version, build, release, deploy, status, sync"
    exit 1
fi

COMMAND=$1
shift

case $COMMAND in
    init)
        log_info "Initializing release management..."
        # Initialize release directory
        mkdir -p "$RELEASE_DIR"
        # Clone repository if not exists
        if [ ! -d "$(basename $GIT_REPO .git)" ]; then
            git clone $GIT_REPO
        fi
        log_info "Release management initialized."
        ;;

    version)
        log_info "Getting current version..."
        # Use git tag to get latest version
        VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
        echo "Current version: ${VERSION#v}"
        ;;

    bump)
        VERSION_TYPE=$1
        if [ -z "$VERSION_TYPE" ]; then
            echo "Usage: $0 bump <major|minor|patch>"
            exit 1
        fi
        log_info "Bumping $VERSION_TYPE version..."
        # Get current version
        CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
        CURRENT_VERSION=${CURRENT_VERSION#v}
        # Parse version
        MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
        MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
        PATCH=$(echo $CURRENT_VERSION | cut -d. -f3)
        
        case $VERSION_TYPE in
            major)
                MAJOR=$((MAJOR + 1))
                MINOR=0
                PATCH=0
                ;;
            minor)
                MINOR=$((MINOR + 1))
                PATCH=0
                ;;
            patch)
                PATCH=$((PATCH + 1))
                ;;
            *)
                log_error "Invalid version type. Use: major, minor, patch"
                exit 1
                ;;
        esac
        
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
        log_info "New version will be: $NEW_VERSION"
        
        # Create and push tag
        git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
        git push origin "v$NEW_VERSION"
        log_info "Version bumped and tagged: v$NEW_VERSION"
        ;;

    build)
        log_info "Building application..."
        # Run build commands
        if [ -f "package.json" ]; then
            npm run build
        elif [ -f "setup.py" ]; then
            python setup.py build
        elif [ -f "Makefile" ]; then
            make build
        elif [ -f "pom.xml" ]; then
            mvn clean package
        else
            log_warn "No standard build configuration found. Skipping build."
        fi
        log_info "Build completed."
        ;;

    release)
        log_info "Creating release..."
        # Get version
        VERSION=$(git describe --tags --abbrev=0 2>/dev/null)
        if [ -z "$VERSION" ]; then
            log_error "No version found. Run 'release bump' first."
            exit 1
        fi
        VERSION=${VERSION#v}
        
        # Create GitHub release
        if [ -n "$GH_TOKEN" ]; then
            gh release create "v$VERSION" \
                --title "Version $VERSION" \
                --notes "Release notes for v$VERSION" \
                --draft
            log_info "GitHub release created (draft)."
        else
            log_warn "GitHub token not set. Skipping GitHub release."
        fi
        
        # Create release directory
        mkdir -p "$RELEASE_DIR/v$VERSION"
        log_info "Release created: v$VERSION"
        ;;

    deploy)
        ENVIRONMENT=$1
        if [ -z "$ENVIRONMENT" ]; then
            echo "Usage: $0 deploy <environment>"
            echo "Environments: dev, staging, prod"
            exit 1
        fi
        log_info "Deploying to $ENVIRONMENT environment..."
        
        # Check environment branch
        case $ENVIRONMENT in
            dev)
                BRANCH="develop"
                ;;
            staging)
                BRANCH="staging"
                ;;
            prod)
                BRANCH="main"
                ;;
            *)
                log_error "Unknown environment: $ENVIRONMENT"
                exit 1
                ;;
        esac
        
        # Deploy based on environment
        case $ENVIRONMENT in
            dev)
                # Dev deployment (e.g., to staging server)
                echo "Deploying to dev environment..."
                ;;
            staging)
                # Staging deployment
                echo "Deploying to staging environment..."
                ;;
            prod)
                # Production deployment (requires confirmation)
                read -p "Are you sure you want to deploy to PRODUCTION? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Deploying to production..."
                else
                    log_warn "Production deployment cancelled."
                    exit 0
                fi
                ;;
        esac
        
        log_info "Deployment to $ENVIRONMENT completed."
        ;;

    sync)
        log_info "Syncing with remote..."
        git pull origin main
        git fetch --tags
        log_info "Sync completed."
        ;;

    status)
        log_info "Release status..."
        echo "Current branch: $(git branch --show-current)"
        echo "Latest tag: $(git describe --tags --abbrev=0 2>/dev/null || echo 'No tags')"
        echo "Working directory status: $(git status --short)"
        ;;

    *)
        log_error "Unknown command: $COMMAND"
        echo "Usage: $0 <command> [options]"
        echo "Commands: init, version, bump, build, release, deploy, status, sync"
        exit 1
        ;;
esac

log_info "Release script completed successfully."