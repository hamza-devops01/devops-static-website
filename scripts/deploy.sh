#!/bin/bash

# ============================================
# DEPLOYMENT SCRIPT - Static Website
# Usage: ./scripts/deploy.sh [environment]
# ============================================

set -e  # Exit on any error

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Environment (default: production)
ENVIRONMENT=${1:-production}
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DEPLOY_LOG="deploy-${TIMESTAMP}.log"

# ============================================
# FUNCTIONS
# ============================================

# Print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "\n${PURPLE}📌 $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Auto-add log files to .gitignore
auto_ignore_logs() {
    local log_file="$1"
    
    # Check if .gitignore exists
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
        print_info ".gitignore created"
    fi
    
    # Check if log pattern already exists
    if ! grep -q "deploy-*.log" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Deployment logs" >> .gitignore
        echo "deploy-*.log" >> .gitignore
        echo "*.log" >> .gitignore
        echo "*.log.*" >> .gitignore
        print_success "Log files added to .gitignore"
    else
        print_info "Log files already in .gitignore"
    fi
}

# ============================================
# MAIN DEPLOYMENT PROCESS
# ============================================

echo -e "\n${PURPLE}🚀 DEPLOYMENT STARTED${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Timestamp: ${YELLOW}$TIMESTAMP${NC}"
echo -e "Log file: ${YELLOW}$DEPLOY_LOG${NC}\n"

# Start logging
exec > >(tee -a "$DEPLOY_LOG") 2>&1

# ============================================
# Auto-add logs to .gitignore
# ============================================

auto_ignore_logs "$DEPLOY_LOG"

# ============================================
# STEP 1: Validate Prerequisites
# ============================================

print_step "1. Validating Prerequisites"

# Check if AWS CLI is installed
if ! command_exists aws; then
    print_warning "AWS CLI not found. Installing..."
    pip install awscli
    if [ $? -eq 0 ]; then
        print_success "AWS CLI installed successfully"
    else
        print_error "Failed to install AWS CLI"
        exit 1
    fi
else
    print_success "AWS CLI is installed"
fi

# Check if git is installed
if ! command_exists git; then
    print_error "Git is not installed"
    exit 1
else
    print_success "Git is installed"
fi

# Check AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    print_warning "AWS credentials not set in environment"
    print_info "Checking AWS config file..."
    if [ -f ~/.aws/credentials ]; then
        print_success "AWS credentials found in ~/.aws/credentials"
    else
        print_error "No AWS credentials found!"
        print_info "Run 'aws configure' to set up credentials"
        exit 1
    fi
else
    print_success "AWS credentials found in environment"
fi

# ============================================
# STEP 2: Check Git Status
# ============================================

print_step "2. Checking Git Status"

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

# Get current branch
BRANCH=$(git branch --show-current)
print_info "Current branch: ${YELLOW}$BRANCH${NC}"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "Uncommitted changes detected!"
    print_info "Changes:"
    git status --porcelain
    echo ""
    read -p "Do you want to continue with uncommitted changes? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi
else
    print_success "Working directory clean"
fi

# Get latest commit info
COMMIT_SHA=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
print_info "Latest commit: ${YELLOW}$COMMIT_SHA${NC}"
print_info "Commit message: ${YELLOW}$COMMIT_MSG${NC}"

# ============================================
# STEP 3: Build the Static Site
# ============================================

print_step "3. Building Static Site"

print_info "Creating dist directory..."
mkdir -p dist

print_info "Copying source files..."
if [ -d "src" ]; then
    cp -r src/* dist/
    print_success "Source files copied from src/ to dist/"
else
    print_warning "src directory not found! Creating default..."
    mkdir -p src
    cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Deployed Site</title>
</head>
<body>
    <h1>🚀 Deployment Successful!</h1>
    <p>This site was deployed using automated scripts.</p>
    <p>Deployed at: <span id="time"></span></p>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF
    cp -r src/* dist/
    print_success "Default site created and copied"
fi

# Add version information
print_info "Adding version information..."
cat > dist/version.json << EOF
{
    "version": "$COMMIT_SHA",
    "deployed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "environment": "$ENVIRONMENT",
    "commit_message": "$COMMIT_MSG",
    "deployed_by": "$(whoami)"
}
EOF
print_success "Version information added"

# ============================================
# STEP 4: Validate Build
# ============================================

print_step "4. Validating Build"

# Check if index.html exists
if [ -f "dist/index.html" ]; then
    print_success "✅ index.html found"
else
    print_error "❌ index.html not found in dist/"
    exit 1
fi

# Check file count
FILE_COUNT=$(find dist -type f | wc -l)
print_info "Total files built: ${YELLOW}$FILE_COUNT${NC}"

# Show build contents
print_info "Build contents:"
ls -la dist/

# Check file sizes
print_info "File sizes:"
find dist -type f -exec ls -lh {} \; | awk '{print $9 " - " $5}'

# ============================================
# STEP 5: Deploy to AWS S3
# ============================================

print_step "5. Deploying to AWS S3"

# Check if S3_BUCKET is set
if [ -z "$S3_BUCKET" ]; then
    print_warning "S3_BUCKET not set in environment"
    if [ -f .env ]; then
        source .env
        print_success "Loaded S3_BUCKET from .env file"
    else
        print_error "S3_BUCKET not configured!"
        print_info "Set S3_BUCKET in environment or .env file"
        exit 1
    fi
fi

print_info "Bucket: ${YELLOW}$S3_BUCKET${NC}"

# Check if bucket exists
if aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1; then
    print_success "Bucket exists"
else
    print_warning "Bucket doesn't exist! Creating..."
    aws s3 mb "s3://$S3_BUCKET" --region ${AWS_REGION:-us-east-1}
    print_success "Bucket created"
fi

# Enable static website hosting
print_info "Enabling static website hosting..."
aws s3 website "s3://$S3_BUCKET" \
    --index-document index.html \
    --error-document error.html
print_success "Static hosting enabled"

# Apply bucket policy for public access
print_info "Applying bucket policy..."
cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$S3_BUCKET/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket "$S3_BUCKET" \
    --policy file:///tmp/bucket-policy.json
print_success "Bucket policy applied"

# Sync to S3
print_info "Syncing files to S3..."
aws s3 sync dist/ "s3://$S3_BUCKET" \
    --delete \
    --cache-control "max-age=3600" \
    --exact-timestamps \
    --acl public-read

if [ $? -eq 0 ]; then
    print_success "✅ Files synced successfully"
else
    print_error "❌ Sync failed!"
    exit 1
fi

# ============================================
# STEP 6: Generate Website URL
# ============================================

print_step "6. Deployment Complete!"

WEBSITE_URL="http://$S3_BUCKET.s3-website-${AWS_REGION:-us-east-1}.amazonaws.com"
echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "🌐 Website URL: ${GREEN}$WEBSITE_URL${NC}"
echo -e "📝 Version: ${YELLOW}$COMMIT_SHA${NC}"
echo -e "📂 Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "📊 Files deployed: ${YELLOW}$FILE_COUNT${NC}"
echo -e "📋 Log file: ${YELLOW}$DEPLOY_LOG${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Save deployment info
mkdir -p deployment-history
cat > deployment-history/latest-deploy.json << EOF
{
    "version": "$COMMIT_SHA",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "environment": "$ENVIRONMENT",
    "url": "$WEBSITE_URL",
    "files": $FILE_COUNT,
    "commit_message": "$COMMIT_MSG"
}
EOF

echo -e "\n${GREEN}🎉 Deployment completed successfully!${NC}"