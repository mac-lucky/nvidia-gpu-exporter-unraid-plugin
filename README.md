<img src="icon.svg" width="96" align="right" alt="">

# NVIDIA GPU Exporter Plugin for Unraid

![Auto Update](https://github.com/mac-lucky/nvidia-gpu-exporter-unraid-plugin/workflows/Auto%20Update%20NVIDIA%20GPU%20Exporter%20Version/badge.svg)
![Validate plugin](https://github.com/mac-lucky/nvidia-gpu-exporter-unraid-plugin/workflows/Validate%20plugin/badge.svg)

An Unraid plugin that installs and supervises
[utkuozdemir/nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter),
which exposes NVIDIA GPU metrics in Prometheus format on port 9835.

The bundled exporter version is kept current automatically: a weekly GitHub
Actions workflow checks upstream releases, bumps the pinned version and tarball
sha256, rebuilds the plg and merges the update.

## Requirements

- Unraid 6.9 or newer
- The Nvidia Driver plugin (for `nvidia-smi`); without it the exporter runs but
  has no GPU data

## Installation

1. Go to the **Plugins** tab in Unraid
2. Click **Install Plugin**
3. Enter the plugin URL:
   ```
   https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-unraid-plugin/main/nvidia_gpu_exporter.plg
   ```
4. Click **Install**

The install downloads the exporter release tarball, verifies its sha256, caches
it on the flash drive (so reinstalls at boot work without internet), installs
the binary to `/usr/local/bin/nvidia-gpu-exporter` and starts the service.

## Settings

The plugin adds a page under **Settings -> User Utilities -> NVIDIA GPU
Exporter** with live status (service, port, exporter version, driver presence),
start/stop/restart buttons and a tail of the service log.

| Setting | Default | Notes |
|---------|---------|-------|
| Listen port | `9835` | TCP port for the metrics endpoint |
| Auto-start on boot | Enabled | Also controls whether Apply restarts a stopped service |
| Log level | `info` | debug, info, warn or error |
| nvidia-smi command | `nvidia-smi` | Command or absolute path the exporter invokes |
| Query fields | `AUTO` | Comma-separated nvidia-smi query fields; AUTO discovers them |
| Telemetry path | `/metrics` | HTTP path of the metrics endpoint |

Settings persist on the flash drive at
`/boot/config/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.cfg` and survive
reboots and plugin updates. Pressing Apply saves them and restarts the service
with the new flags.

## Service control

The page buttons cover the usual cases. From a terminal:

```bash
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh start
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh stop
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh restart
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh status
```

The service logs to `/var/log/nvidia-gpu-exporter.log`.

## Prometheus

Scrape the endpoint like any other exporter:

```yaml
scrape_configs:
  - job_name: nvidia_gpu
    static_configs:
      - targets: ['your-unraid-server:9835']
```

Grafana dashboards built for nvidia_gpu_exporter work as-is, for example
[dashboard 14574](https://grafana.com/grafana/dashboards/14574).

## Uninstall

Removing the plugin stops the service and deletes the binary, the settings
page, the log and the cached tarballs. The config file on the flash drive is
kept so a reinstall picks up your settings; delete
`/boot/config/plugins/nvidia-gpu-exporter/` to remove it completely.

## Development

`src/` is the source of truth; `nvidia_gpu_exporter.plg` is a build artifact
assembled from it and both are committed. After editing files under `src/` (or
the version pins at the top of `build-plg.sh`):

```bash
./build-plg.sh                            # rebuilds nvidia_gpu_exporter.plg
xmllint --noout nvidia_gpu_exporter.plg   # sanity check
```

CI validates every change: it rebuilds from `src/` and fails if the committed
plg differs, then runs xmllint, shellcheck and PHP/JS lints on the embedded
scripts. A plugin release needs a `VERSION` bump in `build-plg.sh` (date-based,
`YYYY.MM.DD` with a letter suffix for same-day releases) plus a matching
changelog entry; Unraid skips updating files when the version is unchanged.
