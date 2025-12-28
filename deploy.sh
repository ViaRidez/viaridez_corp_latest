#!/bin/bash

# Deployment script for Goridez Corp to UAT Server
# Usage: ./deploy.sh [environment]
# Example: ./deploy.sh          (deploys to UAT - default)
#          ./deploy.sh uat       (deploys to UAT)
#          ./deploy.sh production (deploys to Production)

set -e  # Exit on any error

# Configuration
SERVER_USER="ubuntu"
SERVER_HOST="ec2-65-0-181-183.ap-south-1.compute.amazonaws.com"
PEM_FILE="/Users/koushikpanda/Downloads/pritunl-vpn-server.pem"
REMOTE_PATH="/var/www/evtaar-goridez/goridez_corp"
BUILD_PATH="build/web"

# Environment configuration
ENVIRONMENT="${1:-uat}"  # Default to UAT if no argument provided
ENV_FILE=".env.${ENVIRONMENT}"
ENV_NAME=$(echo "$ENVIRONMENT" | tr '[:lower:]' '[:upper:]')

echo "🚀 Starting deployment of Goridez Corp to ${ENV_NAME} server..."

# Step 0: Setup environment file
echo "📋 Setting up environment variables for ${ENV_NAME}..."
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" .env
    echo "✅ Copied $ENV_FILE to .env"
else
    echo "⚠️  Warning: $ENV_FILE not found!"
    echo "   Using existing .env file or .env.example"
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo "⚠️  Copied .env.example to .env (fallback)"
        else
            echo "❌ Error: No .env file found!"
            exit 1
        fi
    fi
fi

# Step 1: Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 3: Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --base-href /corp/

# Check if build was successful
if [ ! -d "$BUILD_PATH" ]; then
    echo "❌ Build failed! Directory $BUILD_PATH not found."
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 4: Create backup on server (optional)
echo "💾 Creating backup on server..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "
    if [ -d $REMOTE_PATH ]; then
        sudo cp -r $REMOTE_PATH ${REMOTE_PATH}_backup_\$(date +%Y%m%d_%H%M%S) || true
    fi
"

# Step 5: Create directory if it doesn't exist
echo "📁 Ensuring remote directory exists..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "sudo mkdir -p $REMOTE_PATH"

# Step 6: Clear old files
echo "🗑️  Clearing old files on server..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "sudo rm -rf $REMOTE_PATH/*"

# Step 7: Upload new files
echo "📤 Uploading files to server..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "mkdir -p /tmp/goridez_corp_web"
scp -i "$PEM_FILE" -r $BUILD_PATH/. $SERVER_USER@$SERVER_HOST:/tmp/goridez_corp_web/

# Step 8: Move files to final location with correct permissions
echo "🔐 Setting up files with correct permissions..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "
    sudo mv /tmp/goridez_corp_web/* $REMOTE_PATH/
    sudo chown -R www-data:www-data $REMOTE_PATH
    sudo chmod -R 755 $REMOTE_PATH
    rm -rf /tmp/goridez_corp_web
"

# Step 9: Restart nginx
echo "🔄 Restarting nginx..."
ssh -i "$PEM_FILE" $SERVER_USER@$SERVER_HOST "sudo systemctl restart nginx"

echo "✅ Deployment completed successfully!"
echo "🌐 Your app should be accessible at: http://$SERVER_HOST:8080/corp"
echo ""
echo "Next steps:"
echo "  1. Verify the deployment by visiting the URL above"
echo "  2. Check nginx logs if there are issues: ssh and run 'sudo tail -f /var/log/nginx/error.log'"
