#####################################################
# Lanchon REPIT - Device Handler                    #
# Copyright 2019, Lanchon                           #
#####################################################

#####################################################
# Lanchon REPIT is free software licensed under     #
# the GNU General Public License (GPL) version 3    #
# and any later version.                            #
#####################################################

### nexus-10

# Disk /dev/block/mmcblk0: 61071360 sectors, 29.1 GiB
# Logical sector size: 512 bytes
# Disk identifier (GUID): 52444E41-494F-2044-4D4D-43204449534B
# Partition table holds up to 128 entries
# First usable sector is 34, last usable sector is 61071326
# Partitions will be aligned on 1-sector boundaries
# Total free space is 16317 sectors (8.0 MiB)

# Number  Start (sector)    End (sector)  Size       Code  Name
#    1            8192           49151   20.0 MiB    0700  efs
#    2           49152           65535   8.0 MiB     0700  param
#    3           65536           98303   16.0 MiB    0700  boot
#    4           98304          163711   31.9 MiB    0700  recovery
#    5          163712          163839   64.0 KiB    0700  metadata
#    6          163840          172031   4.0 MiB     0700  misc
#    7          172032         1253375   528.0 MiB   0700  cache
#    8         1253376         2891775   800.0 MiB   0700  system
#    9         2891776        61063167   27.7 GiB    0700  userdata

device_makeFlashizeEnv="env/arm.zip"

device_makeFilenameConfig="cache=max+wipe-system=1228M"

device_init() {

    device_checkDevice

    # the block device on which REPIT will operate (only one device is supported):

    #sdev=/sys/devices/platform/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0
    sdev=/sys/block/mmcblk0
    spar=$sdev/mmcblk0p

    ddev=/dev/block/mmcblk0
    dpar=/dev/block/mmcblk0p

    sectorSize=512      # in bytes

    # a grep pattern matching the partitions that must be unmounted before REPIT can start:
    #unmountPattern="${dpar}[0-9]\+"
    unmountPattern="/dev/block/mmcblk[^ ]*"

}

device_initPartitions() {

    # the crypto footer size:
    local footerSize=$(( 16384 / sectorSize ))

    # the set of partitions that can be modified by REPIT:
    #     <gpt-number>  <gpt-name>  <friendly-name> <conf-defaults>     <crypto-footer>
    initPartition    7  cache       cache           "same keep ext4"    0
    initPartition    8  system      system          "same keep ext4"    0

    # the set of modifiable partitions that can be configured by the user (overriding <conf-defaults>):
    configurablePartitions="$(seq 7 8)"

}

device_setup() {

    # the number of partitions that the device must have:
    partitionCount=9

    # the set of defined heaps:
    allHeaps="main"

    # the partition data move chunk size (must fit in memory):
    moveDataChunkSize=$(( 256 * MiB ))

    # only call this if you will later use $deviceHeapStart or $deviceHeapEnd:
    detectBlockDeviceHeapRange

    # the size of partitions configured with the 'min' keyword:
    #heapMinSize=$(( 8 * MiB ))

    # the partition alignment:
    heapAlignment=$(( 4 * MiB ))

}

device_setupHeap_main() {

    # the set of contiguous partitions that form this heap, in order of ascending partition start address:
    heapPartitions="$(seq 7 8)"

    # the disk area (as a sector range) to use for the heap partitions:
    heapStart=$(parOldEnd 6)        # one past the end of misc.
    heapEnd=$(parOldEnd 8)          # one past the end of system.

}
