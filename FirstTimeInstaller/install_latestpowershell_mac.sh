#!/bin/bash
#
# First-time PowerShell Core installation script for macOS
#

echo_info () {
    echo -e "\033[32m$1\033[m"
}
echo_error () {
    echo -e "\033[31m$1\033[m" >&2
}

# detect os version
if [ ! `uname` = Darwin ]; then
    echo_error "This platform is not supported."
    exit 1
fi
pkg_file_match="osx.10.12-x64.pkg"
os_ver=`\sw_vers -productversion | awk -F "." '{print $1"."$2}'`
case "$os_ver" in
    "10.11")
        echo_error "OSX El Capitan (10.11) is not supported."
        exit 1
        ;;
    "10.12")
        #echo -e "macOS Sierra (10.12)"
        pkg_file_match="osx.10.12-x64.pkg"
        ;;
    "10.13")
        #echo -e "macOS High Sierra (10.13)"
        pkg_file_match="osx.10.12-x64.pkg"
        ;;
    *)
        #echo -e "macOS version $os_ver"
        pkg_file_match="osx.10.12-x64.pkg"
        ;;
esac

# test sudo
sudo -v
if [ $? -ne 0 ]; then
    echo_error "You must either be root or be able to use sudo."
    exit 1
fi

# detect pkg file
echo_info "Find Latest PowerShell Core release..."
tmp_dir=`mktemp -d`
pkg_url=`\curl -s https://api.github.com/repos/powershell/powershell/releases/latest | grep -E '"browser_download_url".+\.pkg"$' | grep "$pkg_file_match" | awk '{gsub(/\"/,"",$2);print $2}'`
if [ "$pkg_url" = "" ]; then
    echo_error "Failed to get the latest PowerShell Core PKG url."
    exit 1
fi
pkg_name=`basename $pkg_url`

# download pkg file
echo_info "Download $pkg_url..."
echo_info "  to $tmp_dir/$pkg_name"
\curl -s -Lo "$tmp_dir/$pkg_name" $pkg_url

# install package
echo_info "Install PowerShell Core..."
echo_info "sudo installer -pkg $tmp_dir/$pkg_name -target /"
sudo installer -pkg "$tmp_dir/$pkg_name" -target /
