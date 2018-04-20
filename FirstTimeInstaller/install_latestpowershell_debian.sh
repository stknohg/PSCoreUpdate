#!/bin/bash
#
# First-time PowerShell Core installation script for Debian
#

echo_info () {
    echo -e "\e[32m$1\e[m"
}
echo_error () {
    echo -e "\e[31m$1\e[m" >&2
}

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
if [ ! $ID = debian ]; then
    echo_error "This platform is not Debian."
    exit 1
fi
case $VERSION_ID in
    "8"|"9")
        #
        # ref : https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md
        #
        echo_info "Install PowerShell Core..."
        
        # Install system components
        echo_info "sudo apt-get update"
        sudo apt-get update
        echo_info "sudo apt-get install -y apt-transport-https"
        sudo apt-get install -y apt-transport-https
        if [ $VERSION_ID = "9" ]; then
            echo_info "sudo apt-get install -y gnupg"
            sudo apt-get install -y gnupg
        fi

        # Import the public repository GPG keys
        echo_info "wget -q --no-check-certificate https://packages.microsoft.com/keys/microsoft.asc -O - | sudo apt-key add -"
        \wget -q --no-check-certificate https://packages.microsoft.com/keys/microsoft.asc -O - | sudo apt-key add -

        # Register the Microsoft Product feed
        if [ ! -e /etc/apt/sources.list.d/microsoft.list ]; then
            if [ $VERSION_ID = "8" ]; then
                echo_info "sudo sh -c 'echo ""deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main"" > /etc/apt/sources.list.d/microsoft.list'"
                sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main" > /etc/apt/sources.list.d/microsoft.list'
            fi
            if [ $VERSION_ID = "9" ]; then
                echo_info "sudo sh -c 'echo ""deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main"" > /etc/apt/sources.list.d/microsoft.list'"
                sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
            fi
        fi

        # Update the list of products
        echo_info "sudo apt-get update"
        sudo apt-get update
        # Install PowerShell
        echo_info "sudo apt-get install -y powershell"
        sudo apt-get install -y powershell
        exit 0
        ;;
    *)
        echo_error "This version($VERSION_ID) is not supported."
        exit 1
        ;;
esac
