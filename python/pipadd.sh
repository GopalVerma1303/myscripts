#!/bin/bash

#
## Name: pipadd
## Description: Automatically installs pip packages and updates requirements files
## Usage: ./pipadd <package_name>
#
## Install pip-tools if not already installed
#pip install pip-tools
#
## Function to install package and update requirements
#install_and_update() {
#	# Install the package
#	pip install "$1"
#
#	# If requirements.in doesn't exist, create it
#	if [ ! -f requirements.in ]; then
#		touch requirements.in
#	fi
#
#	# Add package to requirements.in if not already present
#	if ! grep -q "^$1" requirements.in; then
#		echo "$1" >>requirements.in
#	fi
#
#	# Compile requirements.in to requirements.txt
#	pip-compile requirements.in
#}
#
## Check if package name is provided
#if [ -z "$1" ]; then
#	echo "Usage: ./pipadd <package_name>"
#	echo "Example: ./pipadd pandas"
#	exit 1
#fi
#
#install_and_update "$1"

# Name: pipadd
# Description: Installs a package and adds it to requirements.txt only if newer version exists
# Usage: ./pipadd <package_name>

if [ -z "$1" ]; then
	echo "Usage: ./pipadd <package_name>"
	echo "Example: ./pipadd pandas"
	exit 1
fi

# Function to extract version number
get_version_number() {
	echo "$1" | sed 's/.*==\([0-9.]*\).*/\1/'
}

# Get current version if package exists in requirements.txt
CURRENT_VERSION=""
if [ -f requirements.txt ]; then
	CURRENT_VERSION=$(grep -i "^$1==" requirements.txt)
fi

# Check latest available version without installing
LATEST_VERSION=$(pip index versions "$1" 2>/dev/null | grep -m1 "Available versions:" | cut -d ":" -f2 | tr ',' '\n' | tr -d ' ' | sort -V | tail -n1)

if [ -z "$LATEST_VERSION" ]; then
	echo "❌ Package $1 not found in PyPI"
	exit 1
fi

# If package already exists in requirements.txt
if [ ! -z "$CURRENT_VERSION" ]; then
	CURRENT_NUM=$(get_version_number "$CURRENT_VERSION")

	# Compare versions
	if [ "$(printf '%s\n' "$LATEST_VERSION" "$CURRENT_NUM" | sort -V | tail -n1)" == "$CURRENT_NUM" ]; then
		echo "ℹ️  Already using latest version ($CURRENT_NUM)"
		exit 0
	fi
fi

# Install the package if we reach here
pip install "$1"

# Get the installed version of the package
VERSION=$(pip freeze | grep -i "^$1==")

# If requirements.txt doesn't exist, create it
if [ ! -f requirements.txt ]; then
	touch requirements.txt
fi

# Remove any existing entry for this package
sed -i "/^$1==/d" requirements.txt

# Add the new package with version
echo "$VERSION" >>requirements.txt

# Sort requirements.txt alphabetically
sort -o requirements.txt requirements.txt

echo "✅ Updated to $VERSION"
