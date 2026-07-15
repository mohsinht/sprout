#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
android_root="$repo_root/apps/mobile/android"
keystore_path="$android_root/upload-keystore.jks"
properties_path="$android_root/key.properties"

find_keytool() {
  local candidate
  local path_keytool=""
  if command -v keytool >/dev/null 2>&1; then
    path_keytool="$(command -v keytool)"
  fi

  for candidate in \
    "${JAVA_HOME:-}/bin/keytool" \
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
    "/Applications/Android Studio.app/Contents/jre/Contents/Home/bin/keytool" \
    "/opt/homebrew/opt/openjdk/bin/keytool" \
    "/usr/local/opt/openjdk/bin/keytool" \
    "$HOME/android-studio/jbr/bin/keytool" \
    "/opt/android-studio/jbr/bin/keytool" \
    "$path_keytool"; do
    [[ -n "$candidate" && -x "$candidate" ]] || continue
    if "$candidate" -help >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

if [[ -e "$keystore_path" || -e "$properties_path" ]]; then
  echo "Android release signing already exists; refusing to overwrite it." >&2
  echo "Back up apps/mobile/android/key.properties and upload-keystore.jks." >&2
  exit 1
fi

if ! keytool_bin="$(find_keytool)"; then
  cat >&2 <<'EOF'
A usable Java keytool was not found.

Install Android Studio's bundled runtime or run:
  brew install openjdk

Then set JAVA_HOME if needed and run this command again.
EOF
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl was not found; it is required to generate a private password." >&2
  exit 1
fi

echo "This creates Sprout's Android release signing identity."
echo "Losing these files can prevent future updates to installed releases."
echo "Using: $keytool_bin"
read -r -p "Type CREATE to continue: " confirmation
if [[ "$confirmation" != "CREATE" ]]; then
  echo "Signing setup cancelled."
  exit 1
fi

umask 077
password="$(openssl rand -hex 32)"
dname="${ANDROID_KEY_DNAME:-CN=Sprout Financial, OU=Mobile, O=Sprout Financial, L=Karachi, ST=Sindh, C=PK}"

"$keytool_bin" -genkeypair \
  -v \
  -keystore "$keystore_path" \
  -storetype PKCS12 \
  -storepass "$password" \
  -keypass "$password" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -alias upload \
  -dname "$dname"

printf '%s\n' \
  "storePassword=$password" \
  "keyPassword=$password" \
  "keyAlias=upload" \
  "storeFile=../upload-keystore.jks" \
  > "$properties_path"

chmod 600 "$keystore_path" "$properties_path"

echo
echo "Android release signing created."
echo "Back up both files securely before distributing an APK:"
echo "  $keystore_path"
echo "  $properties_path"
echo "Neither file is tracked by Git."
