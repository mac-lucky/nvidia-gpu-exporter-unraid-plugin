#!/bin/bash
# XML Validation Script for Unraid Plugin Files

echo "Validating Unraid plugin XML files..."

FILES=("nvidia-gpu-exporter.plg" "nvidia-gpu-exporter-local.plg")

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -n "Validating $file... "
        if xmllint --noout "$file" 2>/dev/null; then
            echo "✅ VALID"
        else
            echo "❌ INVALID"
            echo "Errors:"
            xmllint --noout "$file"
            echo ""
        fi
    else
        echo "⚠️  File $file not found"
    fi
done

echo ""
echo "Validation complete!"
