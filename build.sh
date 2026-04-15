#!/bin/bash

# Download Flutter
echo "Downloading Flutter..."
curl -s https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz | tar xJ

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Disable analytics
flutter config --no-analytics

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web
echo "Building web app..."
flutter build web --release

echo "Build complete!"