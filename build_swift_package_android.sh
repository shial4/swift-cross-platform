#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [-n|--ndk NDK_PATH] [-h|--help]"
    echo "  -n, --ndk NDK_PATH    Set the path to the Android NDK."
    echo "  -h, --help             Display this help message."
    exit 1
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to load configuration from a JSON file
load_config() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        jq -r '.NDK_PATH, .ANDROID_ARCH, .ANDROID_API_LEVEL' "$config_file"
    else
        echo "Configuration file '$config_file' not found."
        exit 1
    fi
}

# Default values
NDK_PATH=""
ANDROID_ARCH=""
ANDROID_API_LEVEL=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--ndk)
            NDK_PATH="$2"
            shift # past argument
            shift # past value
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate NDK path
if [ -z "$NDK_PATH" ]; then
    echo "NDK path is required. Use -n or --ndk to specify it."
    usage
fi

# Load configuration from config.json
config_file="config.json"
config_values=($(load_config "$config_file"))

# Set configuration values from the loaded values or command-line arguments
if [ -n "${config_values[0]}" ]; then
    NDK_PATH="${config_values[0]}"
fi

if [ -n "${config_values[1]}" ]; then
    ANDROID_ARCH="${config_values[1]}"
fi

if [ -n "${config_values[2]}" ]; then
    ANDROID_API_LEVEL="${config_values[2]}"
fi

# Check if required dependencies are in place
if ! command_exists git || ! command_exists adb; then
    echo "Git and/or ADB (Android Debug Bridge) is not installed. Please install them and try again."
    exit 1
fi

# Check if the 'swift' command is available
if ! command -v swift &>/dev/null; then
    echo "Swift is not installed. Installing Swift..."
  
    # Install Swift using swiftly-install.sh
    curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
    swiftly install latest

    # Check if Swift installation was successful
    if ! command -v swift &>/dev/null; then
        echo "Failed to install Swift. Please check the installation and try again."
        exit 1
    fi
fi

SWIFT_TAG=$(swiftly list-available | grep -oE 'swift-[0-9]+\.[0-9]+\.[0-9]+')

# Check if Swift tag was obtained successfully
if [ -z "$SWIFT_TAG" ]; then
    echo "Failed to obtain Swift tag from swiftly. Exiting."
    exit 1
fi

echo "Swift version (tag): $SWIFT_TAG"

# Obtain SWIFT_PATH from swiftly
SWIFT_PATH=$(swiftly which swift)

# Check if SWIFT_PATH was obtained successfully
if [ -z "$SWIFT_PATH" ]; then
    echo "Failed to obtain SWIFT_PATH from 'swiftly which swift'. Exiting."
    exit 1
fi

echo "Swift executable path: $SWIFT_PATH"

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set PACKAGE_DIRECTORY to the script directory
PACKAGE_DIRECTORY="$SCRIPT_DIR"

echo "Using package directory: $PACKAGE_DIRECTORY"

# Step 1: Building the standalone Swift stdlib for Android
echo "Step 1: Building the standalone Swift stdlib for Android"
git checkout "$SWIFT_TAG"

utils/build-script \
  -R \
  --android \
  --android-ndk "$NDK_PATH" \
  --android-arch "$ANDROID_ARCH" \
  --android-api-level "$ANDROID_API_LEVEL" \
  --stdlib-deployment-targets "android-$ANDROID_ARCH" \
  --native-swift-tools-path "$SWIFT_PATH" \
  --native-clang-tools-path "$SWIFT_PATH" \
  --build-swift-tools 0 \
  --build-llvm 0 \
  --skip-build-cmark

# Step 2: Compiling and building the Swift package for Android
echo "Step 2: Compiling and building the Swift package for Android"
"$SWIFT_PATH/swift" build \
  --triple "$ANDROID_ARCH-unknown-linux-android$ANDROID_API_LEVEL" \
  --package-path "$PACKAGE_DIRECTORY"

# Step 3: Deploying build products to the device
echo "Step 3: Deploying build products to the device"
adb devices
adb push "$PACKAGE_DIRECTORY/.build/debug/App" /data/local/tmp  # Modify the path accordingly

# Step 4: Running the Swift package on your Android device
echo "Step 4: Running the Swift package on your Android device"
adb shell LD_LIBRARY_PATH=/data/local/tmp /data/local/tmp/App  # Use the executable name from your package
