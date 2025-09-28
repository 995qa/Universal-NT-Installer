#!/bin/bash

# tools.sh - Other Tools menu

INSTLR_DEVICE="$1"

SCRIPTS_DIR="./scripts"

if [[ -z "$INSTLR_DEVICE" ]]; then
  dialog --msgbox "Missing required argument(s)!" 7 50
  exit 1
fi

while true; do
  ACTION=$(dialog --clear --backtitle "Other Tools" \
    --title "Other Tools" \
    --menu "Choose an option:" 10 60 3 \
    1 "System Information" \
    2 "Partition Manager" \
    3 "Reinstall Grub4dos MBR" \
    3>&1 1>&2 2>&3)
	
	#  4 "Rebuild all Boot Entries" \  (maybe implemented later in future)

  # Cancel or ESC -> Exit menu
  [[ $? -ne 0 || -z "$ACTION" ]] && break

  case "$ACTION" in
    1)
      bash "$SCRIPTS_DIR/sysinfo.sh"
      ;;
    2)
      while true; do
        PM_ACTION=$(dialog --clear --backtitle "Partition Manager" \
          --title "Partition Manager" \
          --menu "Choose an option:" 9 50 2 \
          1 "Partition Editor" \
          2 "Partition Formatter" \
          3>&1 1>&2 2>&3)

        [[ $? -ne 0 || -z "$PM_ACTION" ]] && break

        case "$PM_ACTION" in
          1)
            bash "$SCRIPTS_DIR/partedit.sh" "$INSTLR_DEVICE"
            ;;
          2)
            bash "$SCRIPTS_DIR/partfrmt.sh" "$INSTLR_DEVICE"
            ;;
        esac
      done
      ;;
    3)
      bash "$SCRIPTS_DIR/fixmbr.sh" "$INSTLR_DEVICE"
      ;;
    4)
      dialog --msgbox "Rebuild all Boot Entries feature is not ready yet." 7 42
      ;;
  esac
done
