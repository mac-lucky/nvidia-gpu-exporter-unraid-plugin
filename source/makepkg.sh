#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"
VERSION="$(date +'%Y.%m.%d')"
BASE_DIR="/Users/maclucky/Documents/GitHub/nvidia-gpu-exporter-plugin/source"
TMP_DIR="/tmp/${PLUGIN_NAME}_$(echo $RANDOM)"

echo "Building $PLUGIN_NAME package version $VERSION..."

# Create temporary directory
mkdir -p $TMP_DIR/$VERSION

# Copy plugin files
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/

# Create install directory structure
mkdir -p $TMP_DIR/$VERSION/install

# Create slack-desc file
cat > $TMP_DIR/$VERSION/install/slack-desc << EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME (Nvidia GPU Prometheus Exporter)
$PLUGIN_NAME:
$PLUGIN_NAME: Provides Prometheus metrics for Nvidia GPUs including:
$PLUGIN_NAME: - GPU utilization and memory usage
$PLUGIN_NAME: - Temperature and power consumption
$PLUGIN_NAME: - Fan speed and process information
$PLUGIN_NAME:
$PLUGIN_NAME: Based on utkuozdemir/nvidia_gpu_exporter
$PLUGIN_NAME: 
$PLUGIN_NAME: Package created by mac-lucky
$PLUGIN_NAME:
EOF

# Create doinst.sh script for post-installation
cat > $TMP_DIR/$VERSION/install/doinst.sh << 'EOF'
#!/bin/bash
# Post-installation script

# Run the install script
if [ -f /usr/local/emhttp/plugins/nvidia_gpu_exporter/include/install.sh ]; then
    /usr/local/emhttp/plugins/nvidia_gpu_exporter/include/install.sh
fi
EOF

chmod +x $TMP_DIR/$VERSION/install/doinst.sh

# Set proper permissions
chmod -R 755 $TMP_DIR/$VERSION/usr/

# Create the package
cd $TMP_DIR
makepkg -l y -c y $PLUGIN_NAME-$VERSION.txz

# Generate MD5 checksum
md5sum $PLUGIN_NAME-$VERSION.txz | awk '{print $1}' > $PLUGIN_NAME-$VERSION.txz.md5

echo "Package created: $TMP_DIR/$PLUGIN_NAME-$VERSION.txz"
echo "MD5 checksum: $(cat $PLUGIN_NAME-$VERSION.txz.md5)"

# Copy to packages directory
PACKAGES_DIR="/Users/maclucky/Documents/GitHub/nvidia-gpu-exporter-plugin/packages"
mkdir -p $PACKAGES_DIR
cp $PLUGIN_NAME-$VERSION.txz $PACKAGES_DIR/
cp $PLUGIN_NAME-$VERSION.txz.md5 $PACKAGES_DIR/

echo "Package copied to $PACKAGES_DIR/"

# Clean up temporary directory on request
echo "Temporary files in: $TMP_DIR"
echo "Run 'rm -rf $TMP_DIR' to clean up"
