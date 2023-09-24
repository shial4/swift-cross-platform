# Swift Package project with cross-platform support

[![Android](https://github.com/shial4/swift-cross-platform/workflows/Build%20Swift%20Package%20for%20Android/badge.svg)](https://github.com/shial4/swift-cross-platform/actions)

This repository aims to build a Swift package application with cross-platform support for Android, macOS, Linux, Windows, iOS, and other compatible Swift platforms. To validate and test, we run a GitHub Actions workflow for each supported platform. 

## Description

This project demonstrates the process of building and testing a Swift package application for various platforms, including Android. It includes a shell script that automates the build and deployment process to compatible devices. The repository leverages GitHub Actions to automate testing and validation of the Swift package on multiple platforms.

## Workflow

The GitHub Actions workflow defined in this repository performs the following tasks:
- Installs the necessary tools and dependencies for each platform.
- Sets up the Swift development environment.
- Executes the shell script for building and testing the Swift package.

You can monitor the status of the workflow for each platform using the badges above.

## Usage

To build and test the Swift package application for a specific platform, follow the instructions in the respective workflow defined in the [.github/workflows](.github/workflows) directory.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
