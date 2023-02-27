#!/usr/bin/env bash
# this script will setup the vagrant on the host.
status_vb=$(sytemctl status virtualbox.service /dev/null)
status_vagrant=$(systemctl status vagrant)
vb_gues_plugin=$(vagrant plugin install vagrant-vbguest)
vb_disk_plugin=$(vagrant plugin install vagrant-disksize)

set -x
# installs virtualbox
$status_vb && echo "Virtualbox already installed.."
$status_vb || sudo apt update && sudo apt install virtualbox

# install vagrant
sleep 1
$status_vagrant && echo "Vagrant already installed"
$status_vagrant || sudo apt install vagrant

# installs vagrant plugins

$vb_gues_plugin 
