#!/bin/bash
(
  # Containers em execução
  for ctid in $(pct list | awk '$2=="running"{print $1}'); do
      echo -n "CT $ctid - "
      awk -F ':' '
        /^cores/   {gsub(/^ +| +$/, "", $2); c=$2}
        /^memory/  {gsub(/^ +| +$/, "", $2); m=int($2/1024)"G"}
        END {print "vCPUs="c" memory="m}
      ' /etc/pve/lxc/$ctid.conf
  done

  # VMs em execução
  for vmid in $(qm list | awk '$3=="running"{print $1}'); do
      echo -n "VM $vmid - "
      awk -F ':' '
        /^sockets/ {gsub(/^ +| +$/, "", $2); s=$2}
        /^cores/   {gsub(/^ +| +$/, "", $2); c=$2}
        /^memory/  {gsub(/^ +| +$/, "", $2); m=int($2/1024)"G"}
        /^balloon/ {gsub(/^ +| +$/, "", $2); b=int($2/1024)"G"}
        END {
          if (s=="") s=1
          if (b=="") b="-"
          print "vCPUs="(s*c)" memory="m" balloon="b
        }
      ' /etc/pve/qemu-server/$vmid.conf
  done
)
