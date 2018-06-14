#!/bin/bash
#
# First-time PowerShell Core installation script for RHEL, CentOS, Fedora
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

case "$ID" in
    "centos"|"rhel")
        major_version=`echo $VERSION_ID | awk -F "." '{print $1}'`
        if [ $major_version -lt 7 ]; then
            echo_error "This version($major_version) is not supported."
            exit 1
        fi
        #
        # ref : https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md
        #
        echo_info "Install PowerShell Core..."

        # Register the Microsoft RedHat repository
        echo_info "\curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo"
        \curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

        # Install PowerShell
        echo_info "sudo yum install -y powershell"
        sudo yum install -y powershell
        exit 0
        ;;
    "fedora")
        if [ $VERSION_ID -lt 25 ]; then
            echo_error "This version($VERSION_ID) is not supported."
            exit 1
        fi
        #
        # ref : https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6
        #
        echo -e "\e[32mInstall PowerShell Core...\e[m"

        # Register the Microsoft signature key
        echo_info "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        # Register the Microsoft RedHat repository
        echo_info "\curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo"
        \curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
        
        # Update the list of products
        echo_info "sudo dnf update -y"
        sudo dnf update -y

        # Install a system component (Fedora 26)
        if [ $VERSION_ID = 26 ]; then
            echo_info "sudo dnf install -y compat-openssl10"
            sudo dnf install -y compat-openssl10
        fi

        # Install PowerShell
        echo_info "sudo dnf install -y powershell"
        sudo dnf install -y powershell
        exit 0
        ;;
    *)
        echo_error "This distribution($ID) is not supported."
        exit 1
        ;;
esac