#!/bin/bash
# Assemble nvidia_gpu_exporter.plg from the src/ scripts so the embedded copies
# are byte-identical to what was reviewed and tested.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/src" && pwd)"
OUT="${1:-$(dirname "$0")/nvidia_gpu_exporter.plg}"

# Single source of truth for versions. The auto-update workflow rewrites the
# three lines below and re-runs this script; nothing under src/ carries a version.
VERSION="2026.07.06b"
EXPORTER_VERSION="1.10.0"
EXPORTER_SHA256="bb7c603d923beb57481652ac9848d1aa89da674b56ed99f99b6631418fbd9e56"
DOWNLOAD_URL="https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${EXPORTER_VERSION}/nvidia_gpu_exporter_${EXPORTER_VERSION}_linux_x86_64.tar.gz"

# Guard: a literal ]]> in any embedded text file would break its CDATA section.
# Skip *.png: the icon is base64-encoded (icon_file), never embedded raw.
if grep -rlF ']]>' "$SRC" --exclude='*.png' >/dev/null 2>&1; then
  echo "ERROR: a src file contains ]]> which breaks CDATA" >&2
  grep -rlF ']]>' "$SRC" --exclude='*.png' >&2
  exit 1
fi

run_file() {  # comment, srcfile  -> a <FILE Run="/bin/bash"> block
  printf '<!-- %s -->\n<FILE Run="/bin/bash">\n<INLINE>\n<![CDATA[\n' "$1"
  cat "$SRC/$2"
  printf ']]>\n</INLINE>\n</FILE>\n\n'
}

run_file_with_vars() {  # comment, srcfile -> run_file with the release vars prepended
  printf '<!-- %s -->\n<FILE Run="/bin/bash">\n<INLINE>\n<![CDATA[\n' "$1"
  printf 'EXPORTER_VERSION="%s"\n' "$EXPORTER_VERSION"
  printf 'EXPORTER_SHA256="%s"\n' "$EXPORTER_SHA256"
  printf 'DOWNLOAD_URL="%s"\n' "$DOWNLOAD_URL"
  cat "$SRC/$2"
  printf ']]>\n</INLINE>\n</FILE>\n\n'
}

# md5 of trim(content)+"\n": Unraid writes a <FILE Name> INLINE payload as
# trim($INLINE).PHP_EOL and stores it on disk, then on a later install REPLACES the
# file only if the block carries an <MD5>/<SHA256> that differs from what's there.
# Without a hash it skips any file that already exists, so upgrades never update it.
# PHP trim() strips [ \t\n\r\0\x0B]; replicate that, append one \n, then md5.
md5_inline() {  # srcfile (absolute) -> 32-char lowercase md5 hex
  perl -0777 -pe 's/\A[ \t\n\r\x00\x0B]+//; s/[ \t\n\r\x00\x0B]+\z//' "$1" \
    | { cat; printf '\n'; } | openssl dgst -md5 | sed 's/^.*= //'
}

named_file() {  # comment, dest, mode, srcfile -> a <FILE Name=...> block
  printf '<!-- %s -->\n<FILE Name="%s" Mode="%s">\n<INLINE>\n<![CDATA[' "$1" "$2" "$3"
  cat "$SRC/$4"
  printf ']]>\n</INLINE>\n<MD5>%s</MD5>\n</FILE>\n\n' "$(md5_inline "$SRC/$4")"
}

icon_file() {  # comment, dest, srcpng -> a <FILE Run> that base64-decodes a binary
  # Binaries can't live in CDATA (PNG bytes aren't valid XML text), so ship the
  # icon as base64 and decode it on install. Strip newlines so the output is
  # identical on macOS (build host) and Linux (CI drift check).
  printf '<!-- %s -->\n<FILE Run="/bin/bash">\n<INLINE>\n<![CDATA[\n' "$1"
  printf 'mkdir -p "%s"\n' "$(dirname "$2")"
  printf 'base64 -d > "%s" <<'\''NVICONB64'\''\n' "$2"
  base64 < "$SRC/$3" | tr -d '\n'; printf '\n'
  printf 'NVICONB64\nchmod 0644 "%s"\n]]>\n</INLINE>\n</FILE>\n\n' "$2"
}

{
cat <<XMLHEAD
<?xml version='1.0' standalone='yes'?>

<!DOCTYPE PLUGIN [
<!ENTITY name      "nvidia-gpu-exporter">
<!ENTITY author    "mac-lucky">
<!ENTITY version   "$VERSION">
<!ENTITY gitURL    "https://github.com/mac-lucky/nvidia-gpu-exporter-unraid-plugin">
<!ENTITY pluginURL "&gitURL;/raw/main/nvidia_gpu_exporter.plg">
<!ENTITY supportURL "&gitURL;/issues">
]>

<PLUGIN name="&name;"
        author="&author;"
        version="&version;"
        pluginURL="&pluginURL;"
        support="&supportURL;"
        icon="nvidia_exporter.png"
        iconURL="&gitURL;/raw/main/src/nvidia_exporter.png"
        launch="Settings/nvidia-gpu-exporter"
        min="6.9">

<CHANGES>
###2026.07.06b
- Add a settings page under Settings -> User Utilities -> NVIDIA GPU Exporter
- Settings persist on the flash drive: listen port, auto-start, log level, nvidia-smi command, query fields, telemetry path
- Cache the release tarball on the flash drive and verify its sha256, so the boot-time reinstall works without internet
- One control script now owns start/stop/restart/status (drops the duplicated install-time start logic)
- Replace changed plugin files on upgrade
###2026.07.06
- Updated to nvidia-gpu-exporter v1.10.0
- Auto-updated via GitHub Actions
###2025.11.27
- Fixed control script process detection (changed from pgrep -x to pgrep -f)
- Service status now correctly detects running processes
###2025.10.13
- Updated to nvidia-gpu-exporter v1.4.1
- Auto-updated via GitHub Actions
###2025.10.06
- Updated to nvidia-gpu-exporter v1.4.0
- Auto-updated via GitHub Actions
###2025.08.18
- Updated to nvidia-gpu-exporter v1.3.2
- Auto-updated via GitHub Actions
###2025.01.18
- Initial release of NVIDIA GPU Exporter plugin
- Downloads and installs nvidia-gpu-exporter v1.3.2
- Auto-starts service on boot
- Exports GPU metrics on port 9835
- Simple background service operation
- Clean uninstall support
</CHANGES>

<!--
NVIDIA GPU Exporter Plugin for Unraid

Installs and supervises utkuozdemir/nvidia_gpu_exporter, which exports NVIDIA
GPU metrics in Prometheus format (port 9835 by default). Configure it under
Settings -> User Utilities -> NVIDIA GPU Exporter.

Plugin: https://github.com/mac-lucky/nvidia-gpu-exporter-unraid-plugin
-->

XMLHEAD

run_file           "1. Seed/migrate persistent config on the flash drive (preserves existing values)." install-config.sh
run_file_with_vars "2. Download (or reuse cached), verify and install the exporter binary." install-binary.sh
named_file "3. Control script: start/stop/restart/status, reads the flash config." "/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh" "0755" nvidia-gpu-exporter.sh
named_file "4. Settings page (Settings -> User Utilities -> NVIDIA GPU Exporter)." "/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.page" "0644" nvidia-gpu-exporter.page
icon_file  "5. Plugin icon, base64-decoded on install." "/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia_exporter.png" nvidia_exporter.png
run_file   "6. Post-install: rc.d symlink, start the service, print summary." post-install.sh

printf '<!-- 7. Removal: stop the service, drop binary/pages/log/cached tarballs; keep config. -->\n'
printf '<FILE Run="/bin/bash" Method="remove">\n<INLINE>\n<![CDATA[\n'
cat "$SRC/remove.sh"
printf ']]>\n</INLINE>\n</FILE>\n\n'

printf '</PLUGIN>\n'
} > "$OUT"

# The changelog entries are literal (the auto-update workflow inserts them with
# sed), so a manual VERSION bump must add its own entry; catch a missing one.
if ! grep -q "^###$VERSION\$" "$OUT"; then
  echo "ERROR: <CHANGES> has no ###$VERSION entry; add one next to VERSION=" >&2
  exit 1
fi

echo "Wrote $OUT"
