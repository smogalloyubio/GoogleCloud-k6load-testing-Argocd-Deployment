#!/bin/bash

set -e

echo "🚀 Installing ArgoCD CLI..."


OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH_RAW="$(uname -m)"

# Normalize Architecture
if [[ "$ARCH_RAW" == "x86_64" ]]; then
  ARCH="amd64"
elif [[ "$ARCH_RAW" == "aarch64" || "$ARCH_RAW" == "arm64" ]]; then
  ARCH="arm64"
else
  echo "❌ Unsupported architecture: $ARCH_RAW"
  exit 1
fi

if [[ "$OS" != "linux" ]]; then
  echo "❌ This script is currently optimized for Linux. Detected: $OS"
  exit 1
fi

# Define download URL
VERSION=$(curl -sL https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
URL="https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-$OS-$ARCH"

echo "📥 Downloading ArgoCD CLI $VERSION for $OS/$ARCH..."
curl -sSL -o argocd "$URL"

# Make executable
chmod +x argocd

# Move to PATH (check for sudo availability)
if command -v sudo >/dev/null 2>&1; then
    sudo mv argocd /usr/local/bin/
else
    mv argocd /usr/local/bin/
fi

echo "✅ Verifying installation..."

argocd version --client

echo "🎉 ArgoCD CLI ($VERSION) installed successfully!"