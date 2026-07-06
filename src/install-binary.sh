# EXPORTER_VERSION, EXPORTER_SHA256 and DOWNLOAD_URL are prepended to this
# script by build-plg.sh when the plg is assembled.
# shellcheck disable=SC2154
set -e
echo "Installing NVIDIA GPU Exporter v${EXPORTER_VERSION}..."

CACHE_DIR="/boot/config/plugins/nvidia-gpu-exporter"
TARBALL="$CACHE_DIR/nvidia_gpu_exporter_${EXPORTER_VERSION}_linux_x86_64.tar.gz"
BINARY_PATH="/usr/local/bin/nvidia-gpu-exporter"
TEMP_DIR="/tmp/nvidia-gpu-exporter-install"
LOG_FILE="/var/log/nvidia-gpu-exporter.log"

mkdir -p "$CACHE_DIR"

verify_tarball() { echo "$EXPORTER_SHA256  $1" | sha256sum -c - >/dev/null 2>&1; }

# Reuse the tarball cached on the flash drive when it matches the pinned
# checksum, so the boot-time reinstall works without internet access.
if [ -s "$TARBALL" ] && verify_tarball "$TARBALL"; then
    echo "Using cached tarball $TARBALL"
else
    rm -f "$TARBALL"
    echo "Downloading $DOWNLOAD_URL"
    if ! wget -q --timeout=30 --tries=3 -O "$TARBALL" "$DOWNLOAD_URL"; then
        echo "wget failed, retrying with curl..."
        if ! curl -fsSL --retry 3 --retry-delay 2 -o "$TARBALL" "$DOWNLOAD_URL"; then
            echo "ERROR: failed to download nvidia_gpu_exporter"
            rm -f "$TARBALL"
            exit 1
        fi
    fi
    if ! verify_tarball "$TARBALL"; then
        echo "ERROR: sha256 mismatch on downloaded tarball"
        echo "Expected: $EXPORTER_SHA256"
        sha256sum "$TARBALL" || true
        rm -f "$TARBALL"
        exit 1
    fi
    echo "Download verified (sha256 ok)"
fi

# Drop cached tarballs from older releases to keep the flash drive tidy.
find "$CACHE_DIR" -maxdepth 1 -name 'nvidia_gpu_exporter_*_linux_x86_64.tar.gz' \
    ! -name "$(basename "$TARBALL")" -delete

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
tar -xzf "$TARBALL" -C "$TEMP_DIR"

# The tarball ships the binary as nvidia_gpu_exporter (underscore); it is
# installed hyphenated. Process matching must always use the full path.
BINARY_FILE=$(find "$TEMP_DIR" -name nvidia_gpu_exporter -type f | head -1)
if [ -z "$BINARY_FILE" ]; then
    echo "ERROR: nvidia_gpu_exporter binary not found in tarball"
    ls -la "$TEMP_DIR"
    exit 1
fi
# Unlink first: overwriting a running binary in place fails with "text file busy".
rm -f "$BINARY_PATH"
install -m 0755 "$BINARY_FILE" "$BINARY_PATH"
rm -rf "$TEMP_DIR"

touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
echo "Installed $BINARY_PATH (v${EXPORTER_VERSION})"

if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "WARNING: nvidia-smi not found. Install the Nvidia Driver plugin or the exporter will have no GPU data."
fi
