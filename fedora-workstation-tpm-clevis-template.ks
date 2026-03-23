# Fedora Workstation Kickstart template for unattended install + TPM-backed
# auto-unlock using Clevis in %post.
#
# Replace these placeholders before publishing the file:
#   __HOSTNAME__
#   __TIMEZONE__
#   __ADMIN_USER__
#   __ADMIN_PASSWORD_HASH__
#   __TEMP_LUKS_PASSPHRASE__
#   __TPM_BIND_SCRIPT_URL__
#
# Notes:
# - This template assumes the installer has network access.
# - The install uses a regular LUKS passphrase first, then %post binds Clevis to TPM2.
# - Safer default: keep the temp LUKS passphrase as fallback. Rotate it later.

lang en_US.UTF-8
keyboard us
timezone Asia/Kolkata --utc
network --bootproto=dhcp --device=link --activate --hostname=test
rootpw --lock
user --name=aritraadmin --groups=wheel --password=L3qS4pcaQ3vwk --iscrypted
firewall --enabled --service=ssh
services --enabled=NetworkManager,sshd
selinux --enforcing
bootloader --timeout=1
zerombr
clearpart --all --initlabel

autopart --type=lvm --encrypted --passphrase=L3qS4pcaQ3vwk

reboot

%packages
@workstation-product-environment
curl
clevis
clevis-dracut
clevis-luks
clevis-systemd
cryptsetup
tpm2-tools
%end

%post --log=/root/ks-post.log --erroronfail
set -euxo pipefail

TMP_BIND_SCRIPT="/root/fedora-clevis-tpm-bind.sh"
curl -fsSL "__TPM_BIND_SCRIPT_URL__" -o "$TMP_BIND_SCRIPT"
chmod 700 "$TMP_BIND_SCRIPT"

export TEMP_LUKS_PASSPHRASE='L3qS4pcaQ3vwk'
export TPM2_PCR_BANK='sha256'
export TPM2_PCR_IDS='7'
export REMOVE_TEMP_PASSPHRASE='no'

"$TMP_BIND_SCRIPT"
%end
