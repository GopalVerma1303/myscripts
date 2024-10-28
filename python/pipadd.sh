##!/bin/bash
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

#!/bin/bash

# Name: pipadd
# Description: Installs a package and adds it with version to requirements.txt
# Usage: ./pipadd <package_name>

if [ -z "$1" ]; then
	echo "Usage: ./pipadd <package_name>"
	echo "Example: ./pipadd pandas"
	exit 1
fi

# Install the package
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

echo "✅ Installed $VERSION and updated requirements.txt"
