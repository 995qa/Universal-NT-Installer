
# Universal NT Installer

Universal NT Installer is a lightweight, fast, and versatile setup utility designed to deploy multiple Windows NT family operating systems — from NT 3.1 to XP — within seconds. It supports both modern and legacy systems, making multi-version Windows installation easier and more accessible.

---

## Features

- **Supports a wide range of Windows NT versions:** NT 3.1, NT 3.5, NT 3.51, NT 4.0, Windows 2000, Windows XP (x86 & x64) both vanilla and patched editions.
- **Fast installation:** Deploys OS setups in just a few seconds.
- **Compatible with modern and legacy hardware:** Supports numerous controllers and patches.
- **Open Source:** Licensed under GNU GPLv3 for maximum "open-source" freedom.
- **Cross-platform ISO build:** Supports building bootable ISO images using syslinux (vmlinuz + core.gz) that work on both Linux and Windows systems.
- **Bootable ISO creation:** The folder contents can be directly converted into a bootable ISO file ready for writing to USB or CD/DVD.

---

## Important Notes
- All operating systems used, including Windows®, are trademarks of Microsoft Corporation. This product is not endorsed or affiliated with Microsoft Corporation.
- This project is in **BETA** stage. Not responsible for any data loss, damage, or malfunction. Use at your own risk.
- Installer only supports Legacy Boot/CSM mode. If you want to use the installer in a computer which does not support Legacy Boot/CSM mode, look at the cool project [CSMWrap](https://github.com/FlyGoat/csmwrap) made by [FlyGoat](https://github.com/FlyGoat). It enables CSM support even on UEFI Class 3 systems. But it's still beta and may not work.
- Readme file will contain more information in the future.
- Don't hesitate to report any issues you find. I will try to fix them as best as I can, whenever I get free time.
- For used installation media list for OSes, look at the [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links).
- [Original repository](https://github.com/ages2001/Universal-NT-Installer) developed by ages2001.

---

## System Requirements for Universal NT Installer

- CPU: At least i486
- RAM: 64 MiB of memory
- Disk: MBR/GPT/SGI/SUN scheme and compatible hard disk controller supported by Tiny Core Linux
- Installation media: USB or CD/DVD at least 2 GiB

**NOTE:** For Windows x64 OSes, x86-64 Intel or AMD CPU is required!

---

## OS Requirements and Patches

### Windows NT 3.1 (Vanilla)
- **Controller**: IDE or SATA (IDE)
- **IRQ Assignment**: Disk controller must be assigned to IRQ 14
- **Position**: Primary master (channel 0, position 0) for PATA IDE, SATA first port (port 0) for SATA IDE
- **Filesystem**: FAT12 or FAT16 CHS
- **Disk Layout**: Entire partition must be within first 8.3 GB (CHS-accessible)
- **Free Space**: At least 60 MiB

### Windows NT 3.50 / 3.51 (Vanilla)
- **Controller**: IDE or SATA (IDE)
- **Position**: Primary or secondary master (channel 0 or 1, position 0) for PATA IDE 
- **Filesystem**: FAT12 or FAT16 CHS
- **Disk Layout**: Entire partition must be within first 8.3 GB (CHS-accessible)
- **Free Space**: At least 60 MiB

### Windows NT 3.51 (Patched)
- **Controller**: IDE, SATA (IDE) or AHCI
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA
- **Free Space**: At least 70 MiB
- **Patches Applied**: UniATA, FAT32

### Windows NT 4.00 (Vanilla)
- **Controller**: IDE or SATA (IDE)
- **Filesystem**: FAT12, FAT16 CHS/LBA, or NTFS
- **Disk Layout**: Must reside within first 137.4 GB of disk
- **Free Space**: At least 140 MiB

### Windows NT 4.00 (Patched)
- **Controller**: IDE, SATA (IDE) or AHCI
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA NTFS
- **Free Space**: At least 160 MiB
- **Patches Applied**: UniATA, FAT32, USB 1.x/2.0

### Windows 2000 (Vanilla)
- **Controller**: IDE or SATA (IDE)
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA or NTFS
- **Free Space**: At least 850 MiB

### Windows 2000 (Patched)
- **Controller**: IDE, SATA (IDE), AHCI or NVMe
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA or NTFS
- **Free Space**: At least 790 MiB
- **Patches Applied**: ACPI, USB 1.x/2.0/3.x, AHCI, NVMe, exFAT

### Windows XP (Vanilla)
- **Controller**: IDE or SATA (IDE)
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA or NTFS
- **Free Space**: At least 950 MiB for x86, 1.32 GiB for x64

### Windows XP (Patched)
- **Controller**: IDE, SATA (IDE), AHCI, RAID, eMMC or NVMe
- **Filesystem**: FAT12, FAT16 CHS/LBA, FAT32 CHS/LBA or NTFS
- **Free Space**: At least 980 MiB for x86 NT 5.1, 860 MiB for x86 NT 5.2, 1.42 GiB for x64
- **Patches Applied**: ACPI, PAE, USB 1.x/2.0/3.x, AHCI, RAID, eMMC, NVMe

---

### Notes
- **Drivers for booting**: Successful installation cannot be guaranteed in all cases, as driver-related issues may arise. Also, you can download XP (x86/x64) ported drivers by GeorgeKing from [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links).
- **CHS and LBA**: CHS (Cylinder-Head-Sector) addressing is required for early NT editions and mandates small partition sizes.
- **Boot Partition**: Must exist and be a primary, at least 4 MiB and supported filesystem (FAT12/FAT16/FAT32/NTFS).
- **exFAT Filesystem**: Windows 2000 Patched and Windows XP Vanilla/Patched (x86/x64) can read and write an exFAT partition but cannot boot from it because NTLDR cannot recognize exFAT partitions. So, you cannot install it to exFAT partition. However, you can create/delete/format exFAT partitions using Partition Editor/Formatter.

### How to Change Patched ACPI.SYS version
- In your Universal NT Installer media, look at the `drivers/patched/ACPI` folder. Copy the patched `acpi.sys` file you wanted to be applied to the `drivers/patched/ACPI/NT5x` for appropriate OS. For ex, `NT50` is for Windows 2000.
- For almost all patched acpi.sys files, look at the [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links).

---

## Getting Started

### Prerequisites

- A Linux or Windows environment capable of running ISO building tools supporting syslinux (e.g. `genisoimage`, `mkisofs`, `xorriso`, `mkisofs.exe`).
- Access to the required OS `.WIM` archives (see below).

### Important Note on `.WIM` Archives

The actual OS image archives (`.WIM`) **are not included** in this repository due to their large size. The ISO files can be downloaded from the [Releases](https://github.com/ages2001/Universal-NT-Installer/releases) section.

Please extract these archives from the ISO files available in the [Releases](https://github.com/ages2001/Universal-NT-Installer/releases) and place them inside the `osfiles/` directory before running the installer.

To keep the repository lightweight, all `.WIM` files in `osfiles/` are **ignored by Git**.

---

## Preparing Bootable Media

The installation process consists of booting the target PC from a prepared ISO file written onto a bootable USB drive or CD/DVD.

- Download the ISO file from the [Releases](https://github.com/ages2001/Universal-NT-Installer/releases) section.
- Write the ISO to a **USB drive** (minimum 2 GiB and **FAT16 or FAT32** formatted) using a tool like **Rufus** (Windows) or appropriate software on Linux.
- **For CD/DVDs**, use any standard burning software like UltraISO, PowerISO etc.
- Boot the target machine from the USB or CD/DVD to start installation.
- Follow the on-screen instructions to install the desired Windows NT version.

No additional setup on the target PC is needed beyond booting from the prepared media.

---

## How to Make Your Custom WIM Installation File

If you want to make and add your own custom Windows installations, follow the guidelines below.

- First, install the OS and install the drivers, programs, make settings etc. in a VM or a PC.
    - If you want to **preinstall the driver for Windows 2000, XP (x86/x64) or later**, use **Microsoft Driver Package Installer (DPInst.exe)** utility. You can download it from [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links). For usage, look at the `USAGE.TXT` file.
- **If your OS is Windows NT 3.1, NT 3.50 or NT 3.51**, shutdown the VM or PC and go to [Build WIM Instructions](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#build-wim-instructions) step. **Otherwise**, go to [Sysprep Instructions](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#sysprep-instructions) step.

### Sysprep Instructions

- Download Sysprep tool from [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links).
- Copy files to X:\Sysprep folder (if folder not exist, create it) for appropriate OS where X letter is your OS partition.
- Run Command Prompt and go to X:\Sysprep folder where X letter is your OS partition. _NOTE: For Windows 2000 and XP (x86/x64), you can use `sysprep.inf` file. Example `sysprep.inf` file exists in Sysprep folder. Don't forget to edit it for your drivers' ID, path etc. for sysprep stage. For more information, look at manual or readme files (especially DOC and PDF files) in the Sysprep folder. **Note that Windows NT 4.0 does not have a `sysprep.inf` file!**_
    - **For Windows NT 4.0**, run `sysprep.exe` in Command Prompt and follow instructions.
    - **For Windows 2000**, run `sysprep.exe -pnp` in Command Prompt and follow instructions.
	- **For Windows XP (x86/x64)**, run `sysprep.exe -mini -pnp -reseal -noreboot -quiet` in Command Prompt and follow instructions.
- After running Sysprep, shutdown your VM or PC and go to [Build WIM Instructions](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#build-wim-instructions) step.

### Build WIM Instructions

- Download **wimlib-imagex** tool for Windows or Linux from [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links).
- Copy OS files to an empty folder (for ex, called `osinst`).
    - For VM installations, extract OS files from disk file (VDI, VHD, VMDK etc.) with 7-zip (for download zip, look at the [Useful Tools and Links](https://github.com/ages2001/Universal-NT-Installer?tab=readme-ov-file#useful-tools-and-links)) or other extraction tool.
	- For PC installations, copy OS files from installed partition.
- Run Command Prompt and type `X:\path\to\wimlib-imagex.exe capture "X:\path\to\osinst" wim_name.WIM "Image Name 1"` where X letter is your partition. You can change the name of WIM and image name whatever you want.
    - For adding more image to `wim_name.WIM`, type `X:\path\to\wimlib-imagex.exe append "X:\path\to\osinst_2" wim_name.WIM "Image Name 2"`where X letter is your partition.
- Lastly, copy your WIM file to `W:\osfiles\custom` folder (if `custom` folder not exist, create it) **where W letter is your Universal NT Installer media**.

**NOTE: For Linux**, instructions are almost same, only paths and wimlib-imagex executable are slightly different. For ex, executable is `wimlib-imagex` instead of `wimlib-imagex.exe` and path is `/path/to/osinst` instead of `X:\path\to\osinst`.

---

## ISO Building Instructions

If you want to build or customize the bootable ISO yourself from the repository files, follow the guidelines below.

---

### Linux/WSL

You need to have ISO creation tools that support the syslinux bootloader such as:

- `genisoimage` and `mkisofs` (preferred)
- `xorriso` (alternative)
- `syslinux` (for bootloader binaries like `isolinux.bin`, `vmlinuz`, `core.gz`)

#### Step-by-step Instructions

1. **Clone the repository**:

   ```bash
   git clone https://github.com/ages2001/Universal-NT-Installer.git
   cd Universal-NT-Installer
   ```

2. **Download and extract the OS files**:

   - Go to the [Releases](https://github.com/ages2001/Universal-NT-Installer/releases) page.
   - Download any ISO file available.
   - Extract the ISO using any archive manager (e.g. `7z`, `bsdtar`, or a GUI tool).
   - Copy the contents of the extracted `osfiles/` folder into your local `osfiles/` directory in the repository.

   Example:

   ```bash
   cp -r extracted_folder/osfiles/* ./osfiles/
   ```

3. **Build the ISO**:

   Once the folder structure is complete, run:

   ```bash
   sudo mkisofs -o ../Universal_NT_Installer.iso \
     -b boot/isolinux/isolinux.bin \
     -c boot/isolinux/boot.cat \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
     -J -R -V "UNVNTINSTLR" .
   ```

   This will generate `Universal_NT_Installer.iso` in the parent directory using the current folder's contents.

---

### Windows

For Windows users, an unofficial port of `mkisofs.exe` is available in tools like:

- **Cygwin**
- **MinGW**
- Standalone distributions (e.g. part of `cdrtools`)

However, ISO generation on Windows using `mkisofs.exe` has **not been fully tested** with Universal NT Installer and may result in boot or file structure issues. For best results, I recommend using a **Linux environment or WSL** (Windows Subsystem for Linux).

You may follow the similar steps as above in Linux/WSL to build the ISO.

---

## Useful Tools and Links

- [Used Installation Media List](https://drive.google.com/file/d/1Pj5EklcAfLJ5KSxSBg3OSmzUCfmMvkry/view?usp=sharing)
- [Windows XP (x86/x64) ported drivers v24](https://drive.google.com/file/d/14pGbwTiARHb0bKOodkYsptOJ83eZbzGB/view?usp=sharing)
- [Windows XP (x86/x64) ported drivers v23](https://www.mediafire.com/file/p0ja2gq8y7fkqwr/DP_Ported_XP_DriversCollection_v23.7z/file)
- [Patched ACPI.SYS files](https://drive.google.com/file/d/1Wg1w31vV9ANp3fOzEQvtGfibc5F2dVET/view?usp=sharing)
- [Microsoft Driver Package Installer (DPInst.exe)](https://drive.google.com/file/d/1Y68GJbPDRh65x2oP7touRUhsOq-462f7/view?usp=sharing)
- [Sysprep Tools](https://drive.google.com/file/d/1tRDUHWuXyY38kyL-UU7louKhTq_29PyT/view?usp=sharing)
- [wimlib-imagex](https://www.wimlib.net/)
- [7-zip](https://www.7-zip.org)

---

## License

This project is licensed under the **GNU General Public License v3 (GPLv3)** — see the [LICENSE](LICENSE) file for details.

---

*“Universal NT Installer makes old and new Windows setups easy and fast, all in one place.”*
