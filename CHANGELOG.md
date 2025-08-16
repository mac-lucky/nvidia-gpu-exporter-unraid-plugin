# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-16

### Added

- Initial release of NVIDIA GPU Exporter Plugin for Unraid
- Web-based configuration interface with start/stop/restart controls
- Automatic download and installation of nvidia_gpu_exporter binary
- Configurable listen address, metrics path, and log level
- Real-time service status monitoring
- Log output viewing in the web interface
- Support for nvidia_gpu_exporter v1.3.2
- Comprehensive README with installation and usage instructions

### Features

- Prometheus-compatible GPU metrics export
- Simple one-click service management
- Persistent configuration storage
- Automatic service recovery on system restart
- Clean uninstallation process

### Technical Details

- Based on nvidia_gpu_exporter by utkuozdemir
- Compatible with Unraid 6.9.0 and later
- Uses standard Unraid plugin architecture
- Stores configuration in `/boot/config/plugins/nvidia_gpu_exporter/`
- Logs stored in `/var/log/nvidia_gpu_exporter/`
