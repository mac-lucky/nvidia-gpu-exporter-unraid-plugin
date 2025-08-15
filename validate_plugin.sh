#!/bin/bash
# Validation script for Unraid plugin

echo "Validating plugin XML structure..."

# Check if xmllint is available
if ! command -v xmllint &> /dev/null; then
    echo "Warning: xmllint not found. Please install libxml2-utils to validate XML."
    exit 1
fi

# Validate XML syntax
if xmllint --noout nvidia_gpu_exporter.plg 2>/dev/null; then
    echo "✓ XML syntax is valid"
else
    echo "✗ XML syntax errors found:"
    xmllint --noout nvidia_gpu_exporter.plg
    exit 1
fi

# Check for required elements
echo "Checking required plugin elements..."

# Check for PLUGIN tag with required attributes
if grep -q '<PLUGIN.*name=.*author=.*version=' nvidia_gpu_exporter.plg; then
    echo "✓ PLUGIN tag with required attributes found"
elif grep -q '<PLUGIN' nvidia_gpu_exporter.plg && grep -q 'name=' nvidia_gpu_exporter.plg && grep -q 'author=' nvidia_gpu_exporter.plg && grep -q 'version=' nvidia_gpu_exporter.plg; then
    echo "✓ PLUGIN tag with required attributes found"
else
    echo "✗ PLUGIN tag missing required attributes (name, author, version)"
    exit 1
fi

# Check for CHANGES section
if grep -q '<CHANGES>' nvidia_gpu_exporter.plg; then
    echo "✓ CHANGES section found"
else
    echo "✗ CHANGES section missing"
fi

# Check for FILE sections
file_count=$(grep -c '<FILE' nvidia_gpu_exporter.plg)
if [ $file_count -gt 0 ]; then
    echo "✓ Found $file_count FILE sections"
else
    echo "✗ No FILE sections found"
    exit 1
fi

# Check for remove method
if grep -q 'Method="remove"' nvidia_gpu_exporter.plg; then
    echo "✓ Remove method found"
else
    echo "✗ Remove method missing"
fi

# Check MD5 placeholder
if grep -q 'PLACEHOLDER_MD5' nvidia_gpu_exporter.plg; then
    echo "⚠ MD5 placeholder found - run 'make plugin' to generate actual MD5"
elif grep -q '<MD5>[a-f0-9]\{32\}</MD5>' nvidia_gpu_exporter.plg; then
    echo "✓ MD5 checksum present"
else
    echo "✗ Invalid or missing MD5 checksum"
fi

echo "Plugin validation complete!"
