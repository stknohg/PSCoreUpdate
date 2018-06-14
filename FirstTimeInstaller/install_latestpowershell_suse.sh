#!/bin/bash
#
# First-time PowerShell Core installation script for openSUSE, SLES
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

case "$ID" in
    "opensuse")
        case "$VERSION_ID" in
            "42.2"|"42.3") 
                # skip
                ;;
            *)
                echo_error "This version($VERSION_ID) is not supported."
                exit 1
                ;;
        esac

        #
        # ref : https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6
        #
        echo_info "Install PowerShell Core..."

        # Register the Microsoft signature key
        echo_info "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        # Add the Microsoft Product feed
        #echo_info "curl -s https://packages.microsoft.com/config/opensuse/$VERSION_ID/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo"
        #curl -s "https://packages.microsoft.com/config/opensuse/$VERSION_ID/prod.repo" | sudo tee /etc/zypp/repos.d/microsoft.repo
        # Currently, It seems that the repository is shared with RHEL.
        echo_info "curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo"
        curl -s "https://packages.microsoft.com/config/rhel/7/prod.repo" | sudo tee /etc/zypp/repos.d/microsoft.repo

        # Update the list of products
        # Note : currently, following warning message shows.
        #        "File 'repomd.xml' from repository 'packages-microsoft-com-prod' is unsigned."
        #        I temporary added --no-gpg-checks option for a workaround
        echo_info "sudo zypper --no-gpg-checks --non-interactive update"
        sudo zypper --non-interactive --no-gpg-checks update

        # Install PowerShell
        echo_info "sudo zypper --non-interactive install $package_name"
        sudo zypper --non-interactive install $package_name

        exit 0
        ;;
    "sles")
        major_version=`echo $VERSION_ID | awk -F "." '{print $1}'`
        case $major_version in
            11|12) 
                # skip
                ;;
            *)
                echo_error "This version($major_version) is not supported."
                exit 1
                ;;
        esac

        #
        # ref : https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6
        #
        echo_info "Install PowerShell Core..."

        # Register the Microsoft signature key
        echo_info "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

        # Add the Microsoft Product feed
        #echo_info "curl -s https://packages.microsoft.com/config/sles/$major_version/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo"
        #curl -s "https://packages.microsoft.com/config/sles/$major_version/prod.repo" | sudo tee /etc/zypp/repos.d/microsoft.repo
        # Currently, It seems that the repository is shared with RHEL.
        echo_info "curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo"
        curl -s "https://packages.microsoft.com/config/rhel/7/prod.repo" | sudo tee /etc/zypp/repos.d/microsoft.repo

        # Update the list of products
        # Note : currently, following warning message shows.
        #        "File 'repomd.xml' from repository 'packages-microsoft-com-prod' is unsigned."
        #        I temporary added --no-gpg-checks option for a workaround
        echo_info "sudo zypper --no-gpg-checks --non-interactive update"
        sudo zypper --non-interactive --no-gpg-checks update

        # Install PowerShell
        echo_info "sudo zypper --non-interactive install $package_name"
        sudo zypper --non-interactive install $package_name

        exit 0
        ;;
    *)
        echo_error "This distribution($ID) is not supported."
        exit 1
        ;;
esac
