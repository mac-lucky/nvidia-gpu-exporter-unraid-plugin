#!/bin/bash

# NVIDIA GPU Exporter Plugin Compile Script
# This script helps validate and prepare the plugin for distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_FILE="$PROJECT_ROOT/nvidia_gpu_exporter.plg"

echo "=== NVIDIA GPU Exporter Plugin Validation ==="
echo "Project root: $PROJECT_ROOT"
echo "Plugin file: $PLUGIN_FILE"
echo

# Function to check if file exists
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        echo "✓ $description: $(basename "$file")"
        return 0
    else
        echo "✗ $description: $(basename "$file") - MISSING"
        return 1
    fi
}

# Function to validate XML syntax
validate_xml() {
    local file="$1"
    
    echo "Validating XML syntax..."
    if command -v xmllint >/dev/null 2>&1; then
        if xmllint --noout "$file" 2>/dev/null; then
            echo "✓ XML syntax is valid"
        else
            echo "✗ XML syntax errors found:"
            xmllint --noout "$file"
            return 1
        fi
    else
        echo "⚠ xmllint not available, skipping XML validation"
    fi
}

# Function to check plugin structure
validate_structure() {
    echo "Validating plugin structure..."
    local errors=0
    
    # Check main plugin file
    if ! check_file "$PLUGIN_FILE" "Main plugin file"; then
        ((errors++))
    fi
    
    # Check source files
    if ! check_file "$PROJECT_ROOT/source/nvidia-gpu-exporter/nvidia-gpu-exporter.page" "Web interface page"; then
        ((errors++))
    fi
    
    if ! check_file "$PROJECT_ROOT/source/nvidia-gpu-exporter/nvidia-gpu-exporter.php" "PHP backend"; then
        ((errors++))
    fi
    
    # Check documentation
    if ! check_file "$PROJECT_ROOT/README.md" "Documentation"; then
        ((errors++))
    fi
    
    # Check configuration template
    if ! check_file "$PROJECT_ROOT/config-template.cfg" "Configuration template"; then
        ((errors++))
    fi
    
    # Check icon (optional)
    if check_file "$PROJECT_ROOT/nvidia_exporter.png" "Plugin icon"; then
        echo "  Icon size: $(file "$PROJECT_ROOT/nvidia_exporter.png" 2>/dev/null || echo "unknown")"
    fi
    
    return $errors
}

# Function to validate plugin content
validate_content() {
    echo "Validating plugin content..."
    
    if [[ ! -f "$PLUGIN_FILE" ]]; then
        echo "✗ Plugin file not found"
        return 1
    fi
    
    # Check for required sections
    local required_sections=(
        "PLUGIN"
        "CHANGES"
        "FILE.*nvidia-gpu-exporter.page"
        "FILE.*nvidia-gpu-exporter.php"
        "FILE.*nvidia-gpu-exporter.css"
    )
    
    local errors=0
    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$PLUGIN_FILE"; then
            echo "✓ Found: $section"
        else
            echo "✗ Missing: $section"
            ((errors++))
        fi
    done
    
    # Check version and URLs
    echo "Checking plugin metadata..."
    local version=$(grep -o 'version="[^"]*"' "$PLUGIN_FILE" | cut -d'"' -f2)
    local author=$(grep -o 'author="[^"]*"' "$PLUGIN_FILE" | cut -d'"' -f2)
    local exporter_version=$(grep -o 'exporterVersion "[^"]*"' "$PLUGIN_FILE" | cut -d'"' -f2)
    
    echo "  Plugin version: $version"
    echo "  Author: $author"
    echo "  Exporter version: $exporter_version"
    
    return $errors
}

# Function to test URL accessibility
test_urls() {
    echo "Testing external URLs..."
    
    local exporter_url="https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/tag/v1.3.2"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s --head "$exporter_url" | head -n 1 | grep -q "200 OK"; then
            echo "✓ Exporter URL accessible: $exporter_url"
        else
            echo "⚠ Exporter URL may not be accessible: $exporter_url"
        fi
    else
        echo "⚠ curl not available, skipping URL tests"
    fi
}

# Function to generate checksums
generate_checksums() {
    echo "Generating checksums..."
    
    if command -v md5sum >/dev/null 2>&1; then
        local md5=$(md5sum "$PLUGIN_FILE" | cut -d' ' -f1)
        echo "  MD5: $md5"
    elif command -v md5 >/dev/null 2>&1; then
        local md5=$(md5 -q "$PLUGIN_FILE")
        echo "  MD5: $md5"
    fi
    
    if command -v sha256sum >/dev/null 2>&1; then
        local sha256=$(sha256sum "$PLUGIN_FILE" | cut -d' ' -f1)
        echo "  SHA256: $sha256"
    elif command -v shasum >/dev/null 2>&1; then
        local sha256=$(shasum -a 256 "$PLUGIN_FILE" | cut -d' ' -f1)
        echo "  SHA256: $sha256"
    fi
}

# Function to package plugin
package_plugin() {
    echo "Packaging plugin for distribution..."
    
    local package_dir="$PROJECT_ROOT/dist"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local package_name="nvidia-gpu-exporter-plugin_$timestamp"
    
    mkdir -p "$package_dir"
    
    # Create package directory
    local temp_dir=$(mktemp -d)
    local plugin_dir="$temp_dir/$package_name"
    mkdir -p "$plugin_dir"
    
    # Copy files
    cp "$PLUGIN_FILE" "$plugin_dir/"
    cp "$PROJECT_ROOT/README.md" "$plugin_dir/"
    cp "$PROJECT_ROOT/config-template.cfg" "$plugin_dir/"
    
    if [[ -f "$PROJECT_ROOT/nvidia_exporter.png" ]]; then
        cp "$PROJECT_ROOT/nvidia_exporter.png" "$plugin_dir/"
    fi
    
    # Copy source directory
    cp -r "$PROJECT_ROOT/source" "$plugin_dir/"
    
    # Create archive
    cd "$temp_dir"
    tar -czf "$package_dir/$package_name.tar.gz" "$package_name"
    
    echo "✓ Package created: $package_dir/$package_name.tar.gz"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Main execution
main() {
    echo "Starting plugin validation..."
    echo
    
    local total_errors=0
    
    # Validate structure
    if ! validate_structure; then
        ((total_errors += $?))
    fi
    echo
    
    # Validate XML
    if [[ -f "$PLUGIN_FILE" ]]; then
        if ! validate_xml "$PLUGIN_FILE"; then
            ((total_errors++))
        fi
        echo
    fi
    
    # Validate content
    if ! validate_content; then
        ((total_errors += $?))
    fi
    echo
    
    # Test URLs
    test_urls
    echo
    
    # Generate checksums
    generate_checksums
    echo
    
    # Summary
    if [[ $total_errors -eq 0 ]]; then
        echo "=== VALIDATION SUCCESSFUL ==="
        echo "✓ All checks passed"
        echo
        
        # Ask about packaging
        if [[ "${1:-}" == "--package" ]]; then
            package_plugin
        else
            echo "Run with --package to create distribution archive"
        fi
    else
        echo "=== VALIDATION FAILED ==="
        echo "✗ Found $total_errors error(s)"
        echo "Please fix the issues before distribution"
        exit 1
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "NVIDIA GPU Exporter Plugin Compile Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --package    Create distribution package after validation"
    echo "  --help, -h   Show this help message"
    echo
    echo "This script validates the plugin structure, syntax, and content."
    echo "It checks for required files, validates XML syntax, and tests URLs."
    exit 0
fi

# Run main function
main "$@"