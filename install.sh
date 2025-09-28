#!/bin/bash

# Check for dialog
command -v dialog >/dev/null 2>&1 || {
  echo "This script requires 'dialog'."
  exit 1
}

INSTLR_DEVICE="$1"
OSFILES_DIR="/mnt/isofiles/osfiles"
OS_CFG="./os_list.cfg"
EDITION_CFG="./edition_list.cfg"
SCRIPTS_DIR="./scripts"

# Check if OS archives exist
if [[ ! -d "$OSFILES_DIR" || -z "$(ls -A "$OSFILES_DIR" 2>/dev/null)" ]]; then
  echo "Installation files not found in $OSFILES_DIR."
  exit 1
fi

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

while true; do
  # === Main Menu ===
  ACTION=$(dialog --clear --backtitle "Main Menu" \
    --title "Welcome to the Universal NT Installer!" \
    --nocancel \
    --menu "Please choose an option:" 12 50 5 \
    1 "Install OS" \
    2 "Other Tools" \
    3 "Command Line" \
    4 "Reboot the Computer" \
	5 "About" \
    3>&1 1>&2 2>&3)

  case "$ACTION" in
    1)
	  while true; do
        INSTALL_MODE=$(dialog --clear --backtitle "Install OS" \
          --title "Installation Mode" \
          --menu "Choose which installation file(s) will be scanned:" 10 50 2 \
          1 "Default Installation" \
          2 "Custom Installation" \
          3>&1 1>&2 2>&3)

        [[ $? -ne 0 || -z "$INSTALL_MODE" ]] && break
		
		case "$INSTALL_MODE" in		
		  1)		
            while true; do
              # === OS Selection ===
	          dialog --infobox "Scanning files..." 3 21
		
              declare -a OS_MENU=()
              declare -A INDEX_TO_OSCODE=()
              declare -A INDEX_TO_OSDESC=()
              index=1

              while IFS='=' read -r os_code os_desc; do
  	            OS_SELECTED_WIM="${os_code}.WIM"
                if [[ ! -f "$OSFILES_DIR/$OS_SELECTED_WIM" ]]; then
                  continue
                fi
		
                OS_MENU+=("$index" "$os_desc")
                INDEX_TO_OSCODE["$index"]="$os_code"
                INDEX_TO_OSDESC["$index"]="$os_desc"
                ((index++))
              done < "$OS_CFG"

              OS_SELECTED_INDEX=$(dialog --clear --backtitle "Default Installation" \
                --title "Select Operating System" \
                --menu "Choose an OS to install:" 15 50 7 "${OS_MENU[@]}" 3>&1 1>&2 2>&3)

              [[ $? -ne 0 || -z "$OS_SELECTED_INDEX" ]] && break

              OS_CHOICE="${INDEX_TO_OSCODE[$OS_SELECTED_INDEX]}"
        
	      	  # === Compatibility Check for x64 OSes ===
  	          if [[ "$OS_CHOICE" == *"64"* ]]; then
	    	    CPU_MODE=$(lscpu | grep -i 'CPU op-mode' | awk -F: '{print $2}' | xargs)
	    	    ACPI_SUPPORT=$(check_acpi)
	    	    APIC_SUPPORT=$(check_apic)
		  
	            if [[ "$CPU_MODE" != *"64-bit"* ]]; then
	              dialog --msgbox "The selected OS (${INDEX_TO_OSDESC[$OS_SELECTED_INDEX]}) requires a 64-bit capable CPU.\n\nYour system does not support 64-bit." 8 60
	              continue
	    	    elif [[ "$ACPI_SUPPORT" == "No" ]]; then
	    	    	dialog --msgbox "The selected OS (${INDEX_TO_OSDESC[$OS_SELECTED_INDEX]}) requires an ACPI compliant system.\n\nEither your system does not support ACPI or ACPI is disabled." 8 70
	              continue
	    	    elif [[ "$APIC_SUPPORT" == "No" ]]; then
	    	    	dialog --msgbox "The selected OS (${INDEX_TO_OSDESC[$OS_SELECTED_INDEX]}) requires an APIC compliant system.\n\nEither your system does not support APIC or APIC is disabled." 8 70
	              continue			
	            fi
	          fi
		
	    	  OS_SELECTED_WIM="${OS_CHOICE}.WIM"

              while true; do
                # === Edition Selection ===
	    	    dialog --infobox "Please wait..." 3 18
		  
                declare -a ED_MENU=()
                declare -A INDEX_TO_WIM=()
                declare -A INDEX_TO_DESC=()
                index=1

                while IFS='=' read -r os_code editions; do
                  if [[ "$os_code" == "$OS_CHOICE" ]]; then
                    IFS=',' read -ra ed_arr <<< "$editions"
                    for ed in "${ed_arr[@]}"; do
                      IFS=':' read -r ed_code ed_wim ed_desc <<< "$ed"
                      ED_MENU+=("$index" "$ed_desc")
                      INDEX_TO_WIM["$index"]="$ed_wim"
	    		  	  INDEX_TO_DESC["$index"]="$ed_desc"
                      ((index++))
                    done
                  fi
                done < "$EDITION_CFG"

                EDITION_SELECTED_INDEX=$(dialog --clear --backtitle "Default Installation" \
                  --title "Select OS Edition" \
                  --menu "Choose edition:" 10 60 4 "${ED_MENU[@]}" 3>&1 1>&2 2>&3)

                [[ $? -ne 0 || -z "$EDITION_SELECTED_INDEX" ]] && break
		  
	    	    selected_desc="${INDEX_TO_DESC[$EDITION_SELECTED_INDEX]}"
		  
	    	    if [[ "$selected_desc" =~ Patched ]]; then
 	    	     if [[ "$selected_desc" =~ Windows\ XP || "$selected_desc" =~ Windows\ 2000 ]]; then
 	    	       if [[ "$ACPI_SUPPORT" == "No" ]]; then
  	    	        dialog --msgbox "The selected OS ($selected_desc) requires an ACPI compliant system.\n\nEither your system does not support ACPI or ACPI is disabled." 8 70
  	    	        continue
 	    	       elif [[ "$APIC_SUPPORT" == "No" ]]; then
 	    	         dialog --msgbox "The selected OS ($selected_desc) requires an APIC compliant system.\n\nEither your system does not support APIC or APIC is disabled." 8 70
 	    	         continue
 	    	       fi
 	    	     fi
	    	    fi
          
	    	    OS_SELECTED_WIM_INDEX="${INDEX_TO_WIM[$EDITION_SELECTED_INDEX]}"
                SETUP_TYPE=0
				WIM_IMAGE_INFO="-"

                # === Disk and Partition Selection ===
                bash "$SCRIPTS_DIR/selpart.sh" "$INSTLR_DEVICE" "$OS_SELECTED_WIM" "$OS_SELECTED_WIM_INDEX" "$OS_CHOICE" "$SETUP_TYPE" "$WIM_IMAGE_INFO"
                SELPART_EXIT=$?

                if [[ $SELPART_EXIT -eq 2 ]]; then
                  continue  # back to edition selection
                fi
          
                if [[ $SELPART_EXIT -eq 5 ]]; then
                  dialog --infobox "Rebooting..." 3 16 && exec > /dev/null 2>&1 && exec setsid reboot
                fi

                break 3  # break out of both edition + OS selection + install type selection
              done
            done
			;;
			
	      2)
            CUSTOM_DIR="/mnt/isofiles/osfiles/custom"
            while true; do
              mapfile -t CUSTOM_WIMS < <(find "$CUSTOM_DIR" -maxdepth 1 -type f \( -iname "*.wim" \) | sort)

              if [[ ${#CUSTOM_WIMS[@]} -eq 0 ]]; then
                dialog --msgbox "No custom WIM files found in $CUSTOM_DIR." 7 60
                break
              fi

              declare -a CUSTOM_MENU=()
              index=1
              for f in "${CUSTOM_WIMS[@]}"; do
                fname=$(basename "$f")
                CUSTOM_MENU+=("$index" "$fname")
                INDEX_TO_FILE["$index"]="$f"
                ((index++))
              done

              FILE_SELECTED_INDEX=$(dialog --clear --backtitle "Custom Installation" \
                --title "Select WIM File" \
                --menu "Choose a custom WIM file to install:" 15 60 7 "${CUSTOM_MENU[@]}" \
                3>&1 1>&2 2>&3)

              [[ $? -ne 0 || -z "$FILE_SELECTED_INDEX" ]] && break

              SELECTED_FILE="${INDEX_TO_FILE[$FILE_SELECTED_INDEX]}"

              WIMINFO_OUTPUT=$(wiminfo "$SELECTED_FILE" 2>&1)
              if echo "$WIMINFO_OUTPUT" | grep -q "ERROR"; then
                dialog --msgbox "The selected WIM file is invalid or corrupt:\n\n$(basename "$SELECTED_FILE")" 7 60
                continue
              fi

              declare -a IMAGE_MENU=()
              declare -A INDEX_TO_WIMINDEX=()
              declare -A INDEX_TO_NAME=()
              img_idx=1
			  
			  WIM_IMAGE_INFO=""

              while read -r line; do
                if [[ "$line" =~ ^Index:\ +([0-9]+) ]]; then
                  current_index="${BASH_REMATCH[1]}"
                elif [[ "$line" =~ ^Name:\ +(.*) ]]; then
                  current_name="${BASH_REMATCH[1]}"
				  
				  WIM_IMAGE_INFO="Image $current_index - $current_name"
                  IMAGE_MENU+=("$img_idx" "$WIM_IMAGE_INFO")
                  INDEX_TO_WIMINDEX["$img_idx"]="$current_index"
                  INDEX_TO_NAME["$img_idx"]="$current_name"
                  ((img_idx++))
                fi
              done <<< "$WIMINFO_OUTPUT"

              if [[ ${#IMAGE_MENU[@]} -eq 0 ]]; then
                dialog --msgbox "No valid images found in the selected WIM file." 7 60
                continue
              fi

              while true; do
                IMAGE_SELECTED_INDEX=$(dialog --clear --backtitle "Custom Installation" \
                  --title "Select WIM Image" \
                  --menu "Choose an image to install from $(basename "$SELECTED_FILE"):" 15 70 7 "${IMAGE_MENU[@]}" \
                  3>&1 1>&2 2>&3)

                [[ $? -ne 0 || -z "$IMAGE_SELECTED_INDEX" ]] && break

                OS_SELECTED_WIM="$(basename "$SELECTED_FILE")"
                OS_SELECTED_WIM_INDEX="${INDEX_TO_WIMINDEX[$IMAGE_SELECTED_INDEX]}"
				OS_SELECTED_WIM_IMAGE_NAME="${INDEX_TO_NAME[$IMAGE_SELECTED_INDEX]}"
                OS_CHOICE="Custom"
	   		    SETUP_TYPE=1
				SELECTED_WIM_IMAGE_INFO="Image $OS_SELECTED_WIM_INDEX - $OS_SELECTED_WIM_IMAGE_NAME"

                # === Partition Selection ===
                bash "$SCRIPTS_DIR/selpart.sh" "$INSTLR_DEVICE" "$OS_SELECTED_WIM" "$OS_SELECTED_WIM_INDEX" "$OS_CHOICE" "$SETUP_TYPE" "$SELECTED_WIM_IMAGE_INFO"
                SELPART_EXIT=$?

                if [[ $SELPART_EXIT -eq 2 ]]; then
                  continue
                fi

                if [[ $SELPART_EXIT -eq 5 ]]; then
                  dialog --infobox "Rebooting..." 3 16 && exec > /dev/null 2>&1 && exec setsid reboot
                fi
				
				break 3  # break out of both image + WIM selection + install type selection
			  done
            done
            ;;
		esac
	  done
	  ;;
    2)
      bash "$SCRIPTS_DIR/tools.sh" "$INSTLR_DEVICE"
      ;;
    3)
      clear
      sudo -u tc bash
      ;;
    4)
      dialog --yesno "Do you want to reboot the computer now?" 7 50
      [[ $? -eq 0 ]] && dialog --infobox "Rebooting..." 3 16 && exec > /dev/null 2>&1 && exec setsid reboot
      ;;
	  
	5)
      dialog --backtitle "About" \
        --title "Universal NT Installer (2025)" \
        --msgbox "\
Version: v0.2.0-beta\n\
Made by: ages2001\n\
Website: https://www.github.com/ages2001/Universal-NT-Installer \n\n\
A lightweight Linux-based installer for multiple\n\
Windows NT versions; supporting partitioning,\n\
formatting, and sysprepped image deployment.\n\
Installs in seconds on both modern and legacy systems." 12 70
  ;;
  esac
done
