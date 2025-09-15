#!/bin/bash
(
  # Containers em execução
  for ctid in $(pct list | awk '$2=="running"{print $1}'); do
      echo -n "CT $ctid - "
      awk -F ':' '/^cores/ {gsub(/^ +| +$/, "", $2); c=$2} /^memory/ {gsub(/^ +| +$/, "", $2); m=$2} END{print "cores="c" memory="m}' /etc/pve/lxc/$ctid.conf
  done

  # VMs em execução
  for vmid in $(qm list | awk '$3=="running"{print $1}'); do
      echo -n "VM $vmid - "
      awk -F ':' '/^cores/ {gsub(/^ +| +$/, "", $2); c=$2} /^memory/ {gsub(/^ +| +$/, "", $2); m=$2} END{print "cores="c" memory="m}' /etc/pve/qemu-server/$vmid.conf
  done
)
