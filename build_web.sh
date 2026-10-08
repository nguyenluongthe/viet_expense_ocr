#!/bin/bash
set -e

echo "=== Setup Flutter on Vercel ==="
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "=== Checking Flutter Version ==="
flutter --version

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Building Flutter Web Release ==="
flutter build web --release --base-href "/"

echo "=== Finished Build Successfully ==="
