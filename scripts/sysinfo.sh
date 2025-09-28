#!/bin/bash

# sysinfo.sh - System Information

check_acpi() {
  local acpi_rev
  acpi_rev=$(sudo biosdecode 2>/dev/null | grep -i 'ACPI' | awk '{print $2}' | head -n1)
    
  if [[ -z "$acpi_rev" ]]; then
    if ls /sys/firmware/acpi/tables/* &>/dev/null; then
      echo "Unknown"
    else
      echo "No"
    fi
  else
    echo "$acpi_rev"
  fi
}

check_apic() {
  if [[ -f /sys/firmware/acpi/tables/APIC ]]; then
    echo "Yes"
  else
    echo "No"
  fi
}

check_pae() {
  lscpu | grep -i flags | grep -qw pae
  
  if [[ $? -eq 0 ]]; then
    echo "Yes"
  else
    echo "No"
  fi
}

check_mps() {
    rev=$(sudo biosdecode 2>/dev/null | grep -A1 'Multiprocessor' | grep 'Specification' | awk '{print $NF}')
	
    if [[ -n "$rev" ]]; then
        echo "$rev"
    elif sudo dmesg 2>/dev/null | grep -qi "MP-table"; then
        echo "1.4"
    else
        echo "No"
    fi
}

# --- Video resolution detection ---
get_video_resolution() {
    local fb_modes fb_mode res refresh bpp

    if [[ ! -r /sys/class/graphics/fb0/modes ]]; then
        echo "Default"
        return
    fi

    fb_modes=$(cat /sys/class/graphics/fb0/modes | head -n1)
    [[ -z "$fb_modes" ]] && { echo "Default"; return; }

    fb_mode=${fb_modes#U:}          # remove leading "U:"
    fb_mode=${fb_mode%%-*}          # remove "-refresh" part temporarily
    res=${fb_mode%[pi]}             # remove progressive/interlace char
    refresh=$(echo "$fb_modes" | sed -n 's/.*-\([0-9]\+\).*/\1/p')  # extract refresh rate
    [[ -z "$refresh" ]] && refresh=60

    # Bits per pixel
    if [[ -f /sys/class/graphics/fb0/bits_per_pixel ]]; then
        bpp=$(cat /sys/class/graphics/fb0/bits_per_pixel)
    else
        bpp=8
    fi

    echo "${res}x${bpp} (${refresh}Hz)"
}

dialog --infobox "Scanning the system..." 3 27

# --- CPU architecture ---
CPU_WIDTH=$(lscpu | awk -F: '/CPU op-mode/ {print $2}' | grep -o '64-bit')
if [[ -n "$CPU_WIDTH" ]]; then
  SYSARCH="System Architecture: x86-64 (64-Bit)"
else
  SYSARCH="System Architecture: x86-32 (32-Bit)"
fi

# --- CPU name ---
CPU_NAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2- | sed 's/^[ \t]*//')

# --- CPU cores and threads ---
CPU_CORES=$(lscpu | awk '/^Core\(s\) per socket:/ {print $4}')
CPU_THREADS=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
if [[ -z "$CPU_CORES" ]]; then CPU_CORES="Unknown"; fi
if [[ -z "$CPU_THREADS" ]]; then CPU_THREADS="Unknown"; fi

# --- RAM total + type/speed ---
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
if [[ $TOTAL_RAM_MB -ge 1024 ]]; then
  TOTAL_RAM="$(awk "BEGIN {printf \"%.1f\", $TOTAL_RAM_MB/1024}") GB (${TOTAL_RAM_MB} MB)"
else
  TOTAL_RAM="${TOTAL_RAM_MB} MB"
fi
# RAM_INFO=$(sudo dmidecode -t memory 2>/dev/null | awk -F: '/Type:/ {t=$2} /Speed:/ {s=$2} END{print t, s}' | sed 's/^[ \t]*//')

# --- GPU (primary graphics adapter) ---
GPU_NAME=$(lspci 2>/dev/null | grep -i 'VGA' | grep -vi 'non-vga' | head -n1 | cut -d: -f3- | sed 's/^[ \t]*//')

# --- Screen resolution ---
VIDEO_RES=$(get_video_resolution)
if [[ -z "$VIDEO_RES" ]]; then
  VIDEO_RES="Unknown"
fi

# --- SMBIOS Version ---
SMBIOS_VER=$(sudo dmidecode | grep -i "SMBIOS" | grep -i "present" | sed -E 's/.*SMBIOS[[:space:]]+([0-9]+\.[0-9]+).*/\1/')
if [[ -n "$SMBIOS_VER" ]]; then
  SMBIOS_INFO="System Management BIOS (SMBIOS) Version $SMBIOS_VER"
else
  SMBIOS_INFO="System Management BIOS (SMBIOS) Version Unknown"
fi

# --- ACPI check ---
ACPI_REV=$(check_acpi)
if [[ "$ACPI_REV" == "No" ]]; then
  ACPI_INFO="Advanced Configuration and Power Interface (ACPI) is Not Supported"
else
  ACPI_INFO="Advanced Configuration and Power Interface (ACPI) Revision $ACPI_REV"
fi

# --- APIC check ---
APIC_SUPPORT=$(check_apic)
if [[ "$APIC_SUPPORT" == "Yes" ]]; then
  APIC_INFO="Advanced Programmable Interrupt Controller (APIC) is Supported"
else
  APIC_INFO="Advanced Programmable Interrupt Controller (APIC) is Not Supported"
fi

# --- MPS check ---
MPS_REV=$(check_mps)
if [[ "$MPS_REV" == "No" ]]; then
  MPS_INFO="Multiprocessor Specification (MPS) is Not Supported"
else
  MPS_INFO="Multiprocessor Specification (MPS) Revision $MPS_REV"
fi

# --- PAE check ---
PAE_SUPPORT=$(check_pae)
if [[ "$PAE_SUPPORT" == "Yes" ]]; then
  PAE_INFO="Physical Address Extension (PAE) is Supported"
else
  PAE_INFO="Physical Address Extension (PAE) is Not Supported"
fi

# --- Final output in dialog box ---
INFO_OUTPUT="$SYSARCH
CPU: $CPU_NAME
CPU Cores / Threads: $CPU_CORES / $CPU_THREADS
RAM: $TOTAL_RAM
GPU: $GPU_NAME
Video Resolution: $VIDEO_RES

$SMBIOS_INFO
$ACPI_INFO
$APIC_INFO
$MPS_INFO
$PAE_INFO"

dialog --backtitle "System Information" --title "Hardware Summary" --msgbox "$INFO_OUTPUT" 16 80
