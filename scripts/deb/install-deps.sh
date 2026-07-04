#!/bin/bash
set -euo pipefail

echo "installing dependencies"

DEB_PACKAGES=(
	"curl"
	"acl"
	"bc"
	"binutils"
	"bison"
	"build-essential"
	"dkms"
	"e2tools"
	"file"
	"flex"
	"git"
	"libcap-dev"
	"libelf-dev"
	"libicu-dev"
	"libnuma-dev"
	"libssl-dev"
	"rsync"
	"virtme-ng"
	"liburcu-dev"
	"pipx"
	"qemu-system-common"
	"qemu-system-x86"
	"qemu-utils"
	"tar"
)

sudo apt-get -q update
sudo apt-get -qy install ${DEB_PACKAGES[@]}
