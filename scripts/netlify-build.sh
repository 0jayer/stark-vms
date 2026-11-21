#!/usr/bin/env bash
set -eu

if [ -n "${NETLIFY_CACHE_DIR:-}" ]; then
  FLUTTER_ROOT="$NETLIFY_CACHE_DIR/flutter-sdk"
else
  FLUTTER_ROOT="/tmp/flutter-sdk"
fi

if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  rm -rf "$FLUTTER_ROOT"
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"
export FLUTTER_ROOT

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL:-http://localhost:8080}"
