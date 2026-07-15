#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mobile_root="$repo_root/apps/mobile"
signing_properties="$mobile_root/android/key.properties"
api_base_url="${API_BASE_URL:-https://sprout-2bva.onrender.com}"
symbols_dir="$mobile_root/build/symbols/android-s25u"
apk_path="$mobile_root/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"

find_android_build_tool() {
  local tool="$1"
  local sdk_root build_tools_dir candidate
  for sdk_root in \
    "${ANDROID_SDK_ROOT:-}" \
    "${ANDROID_HOME:-}" \
    "$HOME/Library/Android/sdk" \
    "$HOME/Android/Sdk"; do
    [[ -n "$sdk_root" && -d "$sdk_root/build-tools" ]] || continue
    build_tools_dir="$(find "$sdk_root/build-tools" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
    candidate="$build_tools_dir/$tool"
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

if [[ "$api_base_url" != https://* ]]; then
  echo "Production Android builds require an HTTPS API_BASE_URL." >&2
  exit 1
fi

if [[ ! -f "$signing_properties" ]]; then
  cat >&2 <<'EOF'
Release signing is not configured.

Create apps/mobile/android/key.properties pointing to your private upload
keystore, then run this command again. Never commit either file.

Example key.properties:
  storePassword=<your password>
  keyPassword=<your password>
  keyAlias=upload
  storeFile=../upload-keystore.jks
EOF
  exit 1
fi

for property in storePassword keyPassword keyAlias storeFile; do
  if ! grep -Eq "^${property}=.+" "$signing_properties"; then
    echo "Missing ${property} in apps/mobile/android/key.properties." >&2
    exit 1
  fi
done

cd "$mobile_root"

flutter pub get

if [[ "${CLEAN_BUILD:-false}" == "true" ]]; then
  flutter clean
  flutter pub get
fi

mkdir -p "$symbols_dir"

flutter build apk \
  --release \
  --target-platform android-arm64 \
  --split-per-abi \
  --obfuscate \
  --split-debug-info="$symbols_dir" \
  --dart-define=SPROUT_ENV=production \
  --dart-define="API_BASE_URL=$api_base_url"

if [[ ! -f "$apk_path" ]]; then
  echo "Build finished but the expected ARM64 APK was not found: $apk_path" >&2
  exit 1
fi

if apksigner="$(find_android_build_tool apksigner)"; then
  "$apksigner" verify --verbose "$apk_path"
else
  echo "Warning: apksigner was not found, so the APK signature was not independently verified." >&2
fi

if zipalign="$(find_android_build_tool zipalign)"; then
  "$zipalign" -c -P 16 4 "$apk_path"
else
  echo "Warning: zipalign was not found, so 16 KiB native-library alignment was not independently verified." >&2
fi

echo
echo "Samsung S25 Ultra production APK:"
ls -lh "$apk_path"
echo "Dart symbol files (keep these private for crash symbolication):"
echo "$symbols_dir"
