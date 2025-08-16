# MD5 Checksum Fix

## Issue

The plugin installation was failing with "bad md5" error because the MD5 entity was empty in the plugin XML file.

## Solution

Downloaded the actual binary and calculated its MD5 checksum:

```bash
curl -L "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz" -o /tmp/file.tar.gz
md5sum /tmp/file.tar.gz
```

**Result**: `18fda6e8b4f2efda39523bc75d1410f6`

## Files Updated

1. **nvidia-gpu-exporter.plg**: Updated MD5 entity
2. **nvidia-gpu-exporter-local.plg**: Updated MD5 entity
3. **test-install.sh**: Added MD5 verification step

## Before/After

```xml
<!-- Before -->
<!ENTITY md5 "">

<!-- After -->
<!ENTITY md5 "18fda6e8b4f2efda39523bc75d1410f6">
```

## Verification

- ✅ XML validation still passes
- ✅ MD5 checksum verified for v1.3.2 binary
- ✅ Test script now includes checksum verification

The plugin should now install successfully without MD5 errors.
