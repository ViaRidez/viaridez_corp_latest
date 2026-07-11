#!/bin/bash

# Deployment script for viaRidez CORP Frontend to EC2 via AWS SSM
# Usage: ./deploy.sh [s3-bucket-name]
# Example: ./deploy.sh my-deployment-bucket
#
# This script ONLY deploys to /corp path and does NOT affect /ops or /frontend

set -e  # Exit on any error

# Git Bash on Windows rewrites Unix-like paths (e.g. /corp/ → C:/Program Files/Git/corp/).
# Disable that so --base-href and AWS SSM remote paths stay correct.
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  export MSYS2_ARG_CONV_EXCL='*'
fi

# Configuration
INSTANCE_ID="i-08cfb2c5607298892"
SERVER_USER="ubuntu"
REMOTE_PATH="/var/www/viaridez-evtaar/viaRidez-frontend/corp"
BUILD_PATH="build/web"
S3_BUCKET="${1}"  # S3 bucket for temporary file transfer
APP_NAME="viaridez-corp"

# Check if S3 bucket is provided
if [ -z "$S3_BUCKET" ]; then
    echo "Error: S3 bucket name required for file transfer"
    echo "Usage: ./deploy.sh <s3-bucket-name>"
    echo "Example: ./deploy.sh my-deployment-bucket"
    exit 1
fi

echo "Starting deployment to viaRidez CORP Frontend..."
echo "Instance: $INSTANCE_ID"
echo "S3 Bucket: $S3_BUCKET"
echo "Remote Path: $REMOTE_PATH"
echo ""

# Step 1: Clean previous build
echo "Cleaning previous build..."
flutter clean

# Step 2: Get dependencies
echo "Getting dependencies..."
flutter pub get

# Step 3: Build for web
echo "Building Flutter web app..."
flutter build web --release --base-href="/"

# Check if build was successful
if [ ! -d "$BUILD_PATH" ]; then
    echo "Build failed! Directory $BUILD_PATH not found."
    exit 1
fi

echo "Build completed successfully!"

# Step 4: Create deployment package
echo "Creating deployment package..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEPLOY_PACKAGE="${APP_NAME}-${TIMESTAMP}.tar.gz"
cd build
tar -czf "../$DEPLOY_PACKAGE" web/
cd ..

PACKAGE_SIZE=$(du -h "$DEPLOY_PACKAGE" | cut -f1)
echo "Package created: $DEPLOY_PACKAGE ($PACKAGE_SIZE)"

# Step 5: Upload to S3
echo "Uploading package to S3..."
aws s3 cp "$DEPLOY_PACKAGE" "s3://${S3_BUCKET}/deployments/$DEPLOY_PACKAGE"
echo "Uploaded to S3"

# Step 6: Create backup on server (only for corp path)
echo "Creating backup on server..."
aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --comment "Backup viaRidez CORP frontend" \
    --parameters "commands=[
        'if [ -d $REMOTE_PATH ] && [ -n \"\$(ls -A $REMOTE_PATH 2>/dev/null)\" ]; then',
        '  sudo cp -r $REMOTE_PATH ${REMOTE_PATH}_backup_${TIMESTAMP}',
        '  echo Backup created: ${REMOTE_PATH}_backup_${TIMESTAMP}',
        'else',
        '  echo No existing deployment to backup',
        'fi'
    ]" \
    --output text > /dev/null

echo "Backup command sent"
sleep 3

# Step 7: Generate presigned URL (valid for 10 minutes)
echo "Generating secure download link..."
PRESIGNED_URL=$(aws s3 presign "s3://${S3_BUCKET}/deployments/${DEPLOY_PACKAGE}" --expires-in 600)

echo "Deploying to server..."

# Execute deployment using presigned URL (only affects /corp path)
COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --comment "Deploy viaRidez CORP frontend" \
    --parameters "commands=[
        'cd /tmp',
        'curl -f -o /tmp/${DEPLOY_PACKAGE} \"${PRESIGNED_URL}\"',
        'sudo mkdir -p ${REMOTE_PATH}',
        'mkdir -p /tmp/viaridez_corp_deploy',
        'cd /tmp/viaridez_corp_deploy',
        'tar -xzf /tmp/${DEPLOY_PACKAGE}',
        'sudo rm -rf ${REMOTE_PATH}/*',
        'sudo mv web/* ${REMOTE_PATH}/',
        'sudo chown -R ubuntu:www-data ${REMOTE_PATH}',
        'sudo chmod -R 755 ${REMOTE_PATH}',
        'cd /tmp',
        'rm -rf /tmp/viaridez_corp_deploy',
        'rm -f /tmp/${DEPLOY_PACKAGE}',
        'echo CORP Deployment complete!',
        'ls -lah ${REMOTE_PATH} | head -10'
    ]" \
    --output text --query 'Command.CommandId')

echo "Deployment command sent (ID: $COMMAND_ID)"
echo "Waiting for deployment to complete..."

# Wait for command to complete
sleep 5

# Check command status
for i in {1..12}; do
    STATUS=$(aws ssm get-command-invocation \
        --command-id "$COMMAND_ID" \
        --instance-id "$INSTANCE_ID" \
        --query 'Status' \
        --output text 2>/dev/null || echo "InProgress")

    if [ "$STATUS" = "Success" ]; then
        echo "Deployment completed successfully!"

        # Get command output
        echo ""
        echo "Deployment output:"
        aws ssm get-command-invocation \
            --command-id "$COMMAND_ID" \
            --instance-id "$INSTANCE_ID" \
            --query 'StandardOutputContent' \
            --output text
        break
    elif [ "$STATUS" = "Failed" ]; then
        echo "Deployment failed!"
        echo ""
        echo "Error output:"
        aws ssm get-command-invocation \
            --command-id "$COMMAND_ID" \
            --instance-id "$INSTANCE_ID" \
            --query 'StandardErrorContent' \
            --output text
        exit 1
    else
        echo "Status: $STATUS (waiting... ${i}/12)"
        sleep 5
    fi
done

# Step 8: Cleanup S3 (keep last 5 deployments for this app only)
echo "Cleaning up old S3 deployments..."
aws s3 ls "s3://${S3_BUCKET}/deployments/" | grep "${APP_NAME}-" | sort -r | tail -n +6 | awk '{print $4}' | while read file; do
    aws s3 rm "s3://${S3_BUCKET}/deployments/$file" 2>/dev/null || true
done

# Cleanup local package
rm -f "$DEPLOY_PACKAGE"

echo ""
echo "CORP Deployment completed successfully!"
echo "Deployed to: $REMOTE_PATH"
echo ""
 