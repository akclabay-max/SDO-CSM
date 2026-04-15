#!/bin/bash
# This script builds the Flutter web app locally
# Run this before committing to build the web app

echo "Cleaning previous build..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Building web app (release)..."
flutter build web --release

echo "✅ Web build complete! Ready to deploy."
echo "Next steps:"
echo "  git add build/web/"
echo "  git commit -m 'Build web app for production'"
echo "  git push"
