#!/bin/bash
#
# First-time PowerShell Core installation script for Ubuntu
#

echo_info () {
    echo -e "\e[32m$1\e[m"
}
echo_error () {
    echo -e "\e[31m$1\e[m" >&2
}

# parse arguments
package_name="powershell"
if [ "$1" = "preview" ]; then
    package_name="powershell-preview"
fi

# detect os
if [ ! -e /etc/os-release ]; then
    echo_error "This platform is not supported."
    exit 1
fi
# import /etc/os-release
. /etc/os-release

# test sudo
sudo -v
if [ $? -ne 0 ]; then
    echo_error "You must either be root or be able to use sudo."
    exit 1
fi

# install PowerShell Core
if [ ! $ID = ubuntu ]; then
    echo_error "This platform is not Ubuntu."
    exit 1
fi
case "$VERSION_ID" in
    "20.04"|"18.04"|"16.04")
        echo_info "Install PowerShell..."
        #
        # ref : https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6
        #
        # Import the public repository GPG keys
        echo_info "curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
        \curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        # Register the Microsoft Ubuntu repository
        echo_info "sudo curl -s -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/$VERSION_ID/prod.list"
        sudo \curl -s -o /etc/apt/sources.list.d/microsoft.list "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/prod.list"
        # Update the list of products
        echo_info "sudo apt-get update"
        sudo apt-get update
        # Install PowerShell
        echo_info "sudo apt-get install -y $package_name"
        sudo apt-get install -y $package_name
        exit 0
        ;;
    *)
        echo_error "This version($VERSION_ID) is not supported."
        exit 1
        ;;
esac
