# EasyCF 1.0.1

EasyCF 1.0.1 is the current release of EasyCF for BSDOS.

EasyCF automatically detects supported FAT16/FAT32 partitions on a CompactFlash card, locates MBD/MBH disk images and configures BSDOS without requiring the user to know their physical sector location.

![EasyCF 1.0](images/04-easycf-gui.png)

## Supported hardware

- MB03+ with CompactFlash card
- eLeMeNt ZX with an external MB03+ and CompactFlash card, using `EasyCF_EL.tap`

CompactFlash access is always provided by MB03+. The eLeMeNt ZX itself does not contain the CF interface used by EasyCF.

## What's new in 1.0.1

- added `EasyCF_EL.tap` ESXDOS bootstrap
- `EasyCF_EL.tap` can be started on MB03+ from ESXDOS using DivIDE or DivMMC
- `EasyCF_EL.tap` can also be started on eLeMeNt ZX when an external MB03+ with a CF card is connected
- updated build system and documentation

## Main features

- CompactFlash access through the ATA/IDE interface
- FAT16 and FAT32 support
- up to four primary partitions
- superfloppy FAT16/FAT32 media support
- automatic and manual partition selection
- SPACE override for temporary MANUAL mode
- BSDOS disks 1–255
- MBD and MBH image support
- automatic calculation of the physical LBA of the first BSDOS disk
- per-disk write protection
- FAT32 root-directory preparation tools for Windows and Linux

## Downloads

### Complete package

[**Download EasyCF v1.0.1 ZIP**](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/EasyCF_v1.0.1.zip)

### Individual files

- [EasyCF_MB_BIN.tap](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/EasyCF_MB_BIN.tap) – EasyCF for MB03+
- [EasyCF_EL.tap](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/EasyCF_EL.tap) – ESXDOS bootstrap for MB03+, and for eLeMeNt ZX with an external MB03+
- [EasyCF_documentation.txt](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/EasyCF_documentation.txt) – complete manual
- [PREPARE_EASY_FAT32.bat](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/PREPARE_EASY_FAT32.bat) – Windows FAT32 preparation tool
- [PREPARE_EASY_FAT32.sh](https://github.com/milan-stava/EasyCF/releases/download/v1.0.1/PREPARE_EASY_FAT32.sh) – Linux FAT32 preparation tool

See the [EasyCF 1.0.1 release](https://github.com/milan-stava/EasyCF/releases/tag/v1.0.1) for release notes.

## Important

MBD/MBH disk images must form one physically contiguous area on the media.

Version 1.0.1 has been tested on real hardware, including BSDOS read and write operations on MB03+, startup of `EasyCF_EL.tap` from ESXDOS using both DivIDE and DivMMC, and startup from eLeMeNt ZX with an external MB03+ and CF card.

## Documentation

See `EasyCF_documentation.txt` for the complete user and technical manual.

## Related project

EasySD is the SD-card counterpart of EasyCF and supports MB03+, MB03+ Slim and standalone eLeMeNt ZX.

## Official website

Full HTML documentation, screenshots and project information:

- [English documentation](https://hood.speccy.cz/dwnld/EasySD_CF_infoEN.html)
- [Czech documentation](https://hood.speccy.cz/dwnld/EasySD_CF_infoCZ.html)
- [German documentation](https://hood.speccy.cz/dwnld/EasySD_CF_infoDE.html)
