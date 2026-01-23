#!/bin/bash
set -euo pipefail

# Install wasm-tools from GitHub releases
# https://github.com/bytecodealliance/wasm-tools/releases

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${VERSION:-latest}"

# Detect OS and architecture
detect_platform() {
    local os arch

    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac

    echo "${arch}-${os}"
}

# Get the latest version tag from GitHub API
get_latest_version() {
    curl -s https://api.github.com/repos/bytecodealliance/wasm-tools/releases/latest \
        | grep '"tag_name":' \
        | sed -E 's/.*"v([^"]+)".*/\1/'
}

main() {
    local platform version download_url filename ext

    platform=$(detect_platform)
    echo "Detected platform: $platform"

    if [[ "$VERSION" == "latest" ]]; then
        version=$(get_latest_version)
    else
        version="$VERSION"
    fi
    echo "Installing wasm-tools version: $version"

    # Determine file extension
    if [[ "$platform" == *"windows"* ]]; then
        ext="zip"
    else
        ext="tar.gz"
    fi

    filename="wasm-tools-${version}-${platform}.${ext}"
    download_url="https://github.com/bytecodealliance/wasm-tools/releases/download/v${version}/${filename}"

    echo "Downloading from: $download_url"

    # Create temp directory
    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT

    # Download
    curl -fSL "$download_url" -o "$tmp_dir/$filename"

    # Extract
    echo "Extracting..."
    if [[ "$ext" == "zip" ]]; then
        unzip -q "$tmp_dir/$filename" -d "$tmp_dir"
    else
        tar -xzf "$tmp_dir/$filename" -C "$tmp_dir"
    fi

    # Install
    mkdir -p "$INSTALL_DIR"

    # Find the wasm-tools binary (it's in a subdirectory)
    local binary_path
    binary_path=$(find "$tmp_dir" -name "wasm-tools" -type f -executable 2>/dev/null || \
                  find "$tmp_dir" -name "wasm-tools.exe" -type f 2>/dev/null)

    if [[ -z "$binary_path" ]]; then
        # Try without -executable flag (for compatibility)
        binary_path=$(find "$tmp_dir" -name "wasm-tools" -type f | head -1)
    fi

    if [[ -z "$binary_path" ]]; then
        echo "Error: Could not find wasm-tools binary in archive" >&2
        exit 1
    fi

    cp "$binary_path" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/wasm-tools"

    echo ""
    echo "wasm-tools installed to: $INSTALL_DIR/wasm-tools"

    # Check if install dir is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo ""
        echo "Note: $INSTALL_DIR is not in your PATH."
        echo "Add it with: export PATH=\"\$PATH:$INSTALL_DIR\""
    fi

    # Verify installation
    if command -v "$INSTALL_DIR/wasm-tools" &>/dev/null; then
        echo ""
        echo "Verification:"
        "$INSTALL_DIR/wasm-tools" --version
    fi
}

main "$@"
