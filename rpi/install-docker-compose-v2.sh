#!/bin/sh
# Install Docker Compose V2 plugin (no pip) on Raspberry Pi (ARM)
# - System-wide install to /usr/local/lib/docker/cli-plugins/docker-compose
# - Supports: aarch64 (arm64) and armv7l (armv7)
# - Optional: --version vX.Y.Z (default: latest)

set -eu

COMPOSE_VERSION="latest"   # e.g., v2.27.1 or keep "latest"
TARGET_DIR="/usr/local/lib/docker/cli-plugins"

# ---- Parse args (POSIX) ----
while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      shift
      if [ $# -gt 0 ]; then
        COMPOSE_VERSION="$1"
      else
        echo "Error: --version requires a value" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: sudo sh $0 [--version vX.Y.Z]" >&2
      exit 1
      ;;
  esac
  shift
done

# ---- Require root ----
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo sh $0" >&2
  exit 1
fi

# ---- Check Docker ----
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH." >&2
  echo "Install Docker first, e.g.: curl -fsSL https://get.docker.com | sh" >&2
  exit 1
fi

# ---- Detect architecture ----
ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64)
    BINARY="docker-compose-linux-aarch64"
    ;;
  armv7l|armv7)
    BINARY="docker-compose-linux-armv7"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    echo "Supported: aarch64/arm64, armv7l/armv7" >&2
    exit 1
    ;;
esac

# ---- Determine URL ----
if [ "$COMPOSE_VERSION" = "latest" ]; then
  URL="https://github.com/docker/compose/releases/latest/download/$BINARY"
else
  case "$COMPOSE_VERSION" in
    v*) : ;;           # already has v prefix
    *) COMPOSE_VERSION="v$COMPOSE_VERSION" ;;
  esac
  URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/$BINARY"
fi

echo "Installing Docker Compose V2 plugin ($COMPOSE_VERSION) for $ARCH"
echo "Download URL: $URL"

# ---- Prepare target ----
mkdir -p "$TARGET_DIR"

# ---- Download to temp and install ----
TMP_FILE="$(mktemp)"
if ! curl -fL "$URL" -o "$TMP_FILE"; then
  echo "Download failed. Check network or version tag." >&2
  rm -f "$TMP_FILE"
  exit 1
fi

install -m 0755 "$TMP_FILE" "$TARGET_DIR/docker-compose"
rm -f "$TMP_FILE"
chmod 0755 "$TARGET_DIR/docker-compose"

# ---- Verify ----
echo "Verifying installation..."
if docker compose version >/dev/null 2>&1; then
  docker compose version
  echo "SUCCESS: Docker Compose V2 plugin installed."
  echo "Use: docker compose up -d"
else
  echo "WARN: 'docker compose' not detected." >&2
  echo "Possible causes: old docker CLI (needs 20.10+), or plugin discovery path issue." >&2
  echo "Try restarting your shell or running: hash -r" >&2
  exit 1
fi