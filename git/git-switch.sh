#!/bin/bash

# File: git-switch.sh
# Description: Script to easily switch between different Git accounts and list all configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print with color
print_colored() {
	local color=$1
	local message=$2
	echo -e "${color}${message}${NC}"
}

# Function to print section header
print_header() {
	local message=$1
	print_colored $BLUE "\n=== $message ==="
	echo "------------------------"
}

# Function to display current Git configuration
show_current_config() {
	print_header "Current Git Configuration"
	echo "User Name: $(git config user.name)"
	echo "User Email: $(git config user.email)"
}

# Function to list all Git configurations
list_all_configs() {
	# System configurations
	print_header "System Level Git Configuration"
	if git config --system --list | grep "user" >/dev/null; then
		git config --system --list | grep "user"
	else
		echo "No system level user configurations found"
	fi

	# Global configurations
	print_header "Global Git Configuration"
	if git config --global --list | grep "user" >/dev/null; then
		git config --global --list | grep "user"
	else
		echo "No global user configurations found"
	fi

	# Local configurations (if inside a Git repository)
	if git rev-parse --git-dir >/dev/null 2>&1; then
		print_header "Local Git Configuration (Current Repository)"
		if git config --local --list | grep "user" >/dev/null; then
			git config --local --list | grep "user"
		else
			echo "No local user configurations found"
		fi
	fi

	# SSH configurations
	print_header "SSH Configurations"
	if [ -f ~/.ssh/config ]; then
		cat ~/.ssh/config
	else
		echo "No SSH config file found"
	fi

	# List SSH keys in agent
	print_header "SSH Keys in Agent"
	if ssh-add -l >/dev/null 2>&1; then
		ssh-add -l
	else
		echo "No SSH keys found in agent"
	fi
}

# Function to switch Git account
switch_account() {
	local scope=$1
	local name=$2
	local email=$3

	# Apply the configuration
	if [ "$scope" == "--global" ]; then
		git config --global user.name "$name"
		git config --global user.email "$email"
		print_colored $GREEN "\n✔ Global Git account switched successfully!"
	else
		if git rev-parse --git-dir >/dev/null 2>&1; then
			git config user.name "$name"
			git config user.email "$email"
			print_colored $GREEN "\n✔ Local Git account switched successfully!"
		else
			print_colored $RED "Error: Not a git repository. Use --global flag or run from within a git repository."
			exit 1
		fi
	fi
}

# Show usage instructions
usage() {
	echo "Usage:"
	echo "  ./git-switch.sh [options] <name> <email>"
	echo ""
	echo "Options:"
	echo "  --global    Apply settings globally"
	echo "  --local     Apply settings to current repository only (default)"
	echo "  --show      Show current Git configuration"
	echo "  --list      List all Git user configurations and SSH settings"
	echo "  --help      Show this help message"
	echo ""
	echo "Examples:"
	echo "  ./git-switch.sh --global \"John Doe\" \"john@example.com\""
	echo "  ./git-switch.sh --local \"John Doe\" \"john@example.com\""
	echo "  ./git-switch.sh --show"
	echo "  ./git-switch.sh --list"
}

# Main script logic
main() {
	case "$1" in
	--help)
		usage
		exit 0
		;;
	--show)
		show_current_config
		exit 0
		;;
	--list)
		list_all_configs
		exit 0
		;;
	--global | --local)
		if [ $# -ne 3 ]; then
			print_colored $RED "Error: Name and email required"
			usage
			exit 1
		fi
		switch_account "$1" "$2" "$3"
		show_current_config
		;;
	*)
		if [ $# -eq 2 ]; then
			# Default to local scope if not specified
			switch_account "--local" "$1" "$2"
			show_current_config
		else
			print_colored $RED "Error: Invalid arguments"
			usage
			exit 1
		fi
		;;
	esac
}

# Execute main script
main "$@"
