#!/bin/bash

INSTLR_DEVICE="$1"

if [[ -z "$INSTLR_DEVICE" ]]; then
  dialog --msgbox "Missing required argument(s)!" 7 50
  exit 1
fi

declare -a DISK_MENU=()
declare -A DISK_INFO=()

scan_disks() {
  dialog --infobox "Scanning disks..." 3 22

  for disk in /dev/sd? /dev/nvme?n? /dev/mmcblk?; do
    [[ ! -b "$disk" ]] && continue
    type=$(lsblk -dn -o TYPE "$disk" 2>/dev/null)
    [[ "$type" != "disk" ]] && continue
	
	#  CNTRLR=$(get_disk_interface_type "$disk")
	
	#  case "$CNTRLR" in
    #    "IDE"|"SATA (IDE)"|"AHCI"|"RAID"|"eMMC"|"NVMe"|"SCSI")
    #      ;;  # accepted types -> do nothing
    #    *)
    #      continue  # skip unsupported types
    #      ;;
    #  esac
    
    # Installer device skipped
    [[ $INSTLR_DEVICE == $disk* ]] && continue

    part_table=$(parted -sm "$disk" print 2>/dev/null | grep "^/dev" | cut -d: -f6 | head -n 1)
    [[ -z "$part_table" ]] && part_table="Unknown"
    [[ "$part_table" == "msdos" ]] && part_table="MBR"
    [[ "$part_table" == "gpt" ]] && part_table="GPT"
	
	[[ "$part_table" != "MBR" ]] && continue  # Only MBR disks will be displayed
	
	CNTRLR=$(get_disk_interface_type "$disk")

    disk_basename=$(basename "$disk")
    sector_size=$(cat /sys/block/$disk_basename/queue/hw_sector_size 2>/dev/null || echo 512)
    sector_count=$(cat /sys/block/$disk_basename/size 2>/dev/null || echo 0)
    size_bytes=$((sector_count * sector_size))
    size_kb=$((size_bytes / 1024))
    size_fmt=$(format_size "$size_kb")

    DISK_MENU+=("$disk" "Size: $size_fmt | Type: $part_table | Cntrlr: $CNTRLR")
    DISK_INFO["$disk,type"]="$part_table"
    DISK_INFO["$disk,size"]="$size_fmt"
  done

  if [[ ${#DISK_MENU[@]} -eq 0 ]]; then
    dialog --msgbox "No suitable disks found." 7 50
    exit 1
  fi
}

# Format size function: input in KB, output in KB/MB/GB/TB with decimals
format_size() {
  local size_kb=$1
  local result

  if awk "BEGIN {exit !($size_kb < 1024)}"; then
    result=$(awk -v kb="$size_kb" 'BEGIN { val=kb; fmt=sprintf("%.2f KB", val); print fmt }')
  elif awk "BEGIN {exit !($size_kb < 1024*1024)}"; then
    result=$(awk -v kb="$size_kb" 'BEGIN { val=kb/1024; fmt=sprintf("%.2f MB", val); print fmt }')
  elif awk "BEGIN {exit !($size_kb < 1024*1024*1024)}"; then
    result=$(awk -v kb="$size_kb" 'BEGIN { val=kb/1024/1024; fmt=sprintf("%.2f GB", val); print fmt }')
  else
    result=$(awk -v kb="$size_kb" 'BEGIN { val=kb/1024/1024/1024; fmt=sprintf("%.2f TB", val); print fmt }')
  fi

  echo "$result"
}

get_disk_interface_type() {
  local disk="$1"
  local sys_path pci_addr pci_id_short lspci_out

  # Ensure we're using only the disk name (e.g., "sda" from "/dev/sda")
  disk=$(basename "$disk")
  
  if [[ "$disk" == *nvme* ]]; then
    echo "NVMe"
    return
  fi
  
  if [[ "$disk" == *mmc* ]]; then
    if [[ -e "/sys/block/${disk}boot0" || -e "/sys/block/${disk}boot1" ]]; then
      echo "eMMC"
    else
      echo "SD/MMC"
    fi
    return
  fi
  
  # Get the sysfs path for the device
  sys_path=$(readlink -f "/sys/block/$disk/device" 2>/dev/null)
  [[ -z "$sys_path" ]] && { echo "Unknown"; return; }

  # Extract the PCI address (e.g., 0000:00:1f.2 or 00:1f.2)
  pci_addr=$(echo "$sys_path" | grep -oE '([[:alnum:]]{4}:)?[0-9a-f]{2}:[0-9a-f]{2}\.[0-9]' | tail -n1)
  [[ -z "$pci_addr" ]] && { echo "Unknown"; return; }

  # Remove domain part if present (0000:) for use in lspci
  pci_id_short="${pci_addr#0000:}"

  # Get lspci output and convert to lowercase
  lspci_out=$(lspci -s "$pci_id_short" 2>/dev/null | tr '[:upper:]' '[:lower:]')
  [[ -z "$lspci_out" ]] && { echo "Unknown"; return; }

  # Identify controller type
  if echo "$lspci_out" | grep -qi "sata"; then
    if echo "$lspci_out" | grep -qi "ahci"; then
      echo "AHCI"
    else
      echo "SATA (IDE)"
    fi
    return
  fi

  if echo "$lspci_out" | grep -qi "ide"; then
    echo "IDE"
    return
  fi

  if echo "$lspci_out" | grep -qi "raid"; then
    echo "RAID"
    return
  fi
  
  if echo "$lspci_out" | grep -qi "bolt"; then
    echo "Thunderbolt"
	return
  fi
  
  if echo "$lspci_out" | grep -qi "usb"; then
    if echo "$lspci_out" | grep -qiE "xhci|extensible "; then
      echo "USB 3.x"
    elif echo "$lspci_out" | grep -qiE "ehci|enhanced|[[:space:]]2\.0[[:space:]]"; then
      echo "USB 2.0"
    elif echo "$lspci_out" | grep -qiE "uhci|ohci|universal|open|[[:space:]]1\.1[[:space:]]|[[:space:]]1\.0[[:space:]]"; then
      echo "USB 1.x"
    else
      echo "USB"
    fi
    return
  fi
  
  if echo "$lspci_out" | grep -qiE 'firewire|ieee'; then
    echo "IEEE 1394"
    return
  fi
  
  if echo "$lspci_out" | grep -qi "sas"; then
    echo "SAS"
    return
  fi

  if echo "$lspci_out" | grep -qi "scsi"; then
    echo "SCSI"
    return
  fi
  
  if echo "$lspci_out" | grep -qiE 'pcmcia|cardbus'; then
    echo "PCMCIA"
    return
  fi

  echo "Unknown"
}

scan_disks

while true; do
  # === Disk selection ===
  DISK_SELECTED=$(dialog --clear --backtitle "Reinstall Grub4dos MBR" \
    --title "Select Disk" \
    --menu "Choose the disk for reinstalling Grub4dos MBR:" 18 70 10 "${DISK_MENU[@]}" 3>&1 1>&2 2>&3)
  
  [[ $? -ne 0 || -z "$DISK_SELECTED" ]] && break

  # === Confirmation before MBR update ===
  dialog --yesno "WARNING!\n\nYou are about to reinstall the Grub4dos MBR on $DISK_SELECTED.\nThis may overwrite the existing MBR.\n\nDo you want to continue?" 12 60
  if [[ $? -ne 0 ]]; then
    continue
  fi

  # === Update MBR ===
  if [[ -f /tmp/files/bootldr/bootlace.com ]]; then
    chmod 777 /tmp/files/bootldr/bootlace.com
    if sudo /tmp/files/bootldr/bootlace.com "$DISK_SELECTED" >/dev/null 2>&1; then
      dialog --msgbox "MBR successfully updated on $DISK_SELECTED." 7 50
    else
      dialog --msgbox "Error: Failed to update MBR on $DISK_SELECTED!" 7 50
    fi
  else
    dialog --msgbox "Error: bootlace.com not found!" 7 50
  fi

  continue
done
