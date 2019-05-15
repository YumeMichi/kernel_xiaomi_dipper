# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Polar Kernel by YumeMichi @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=equuleus
supported.versions=9
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=auto;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel install
ui_print "Decompressing boot image..."
dump_boot;

# begin ramdisk changes
rm -fr $ramdisk/overlay

if [ -d $ramdisk/.backup ]; then
  ui_print "Patching ramdisk..."
  patch_cmdline "skip_override" "skip_override"

  chmod +x /tmp/anykernel/overlay/*.sh
  mv /tmp/anykernel/overlay/init.polar.rc /tmp/anykernel/overlay/init.$(getprop ro.hardware).rc
  mv /tmp/anykernel/overlay $ramdisk
else
  patch_cmdline "skip_override" ""
  ui_print 'WARNING: Magisk is not installed, some tweaks will be missing!'
fi

mountpoint -q /data && {
  # Install second-stage late init script
  mkdir -p /data/adb/service.d
  cp /tmp/anykernel/95-polar.sh /data/adb/service.d
  chmod +x /data/adb/service.d/95-polar.sh

  # Optimize F2FS extension list (@arter97)
  find /sys/fs/f2fs_dev -name extension_list | while read list; do
    if grep -q odex "$list"; then
      echo "Extensions list up-to-date: $list"
      continue
    fi

    echo "Updating extension list: $list..."

    echo "Clearing extension list..."

    HOT=$(cat $list | grep -n 'hot file extens' | cut -d : -f 1)
    COLD=$(($(cat $list | wc -l) - $HOT))

    COLDLIST=$(head -n$(($HOT - 1)) $list | grep -v ':')
    HOTLIST=$(tail -n$COLD $list)

    echo $COLDLIST | tr ' ' '\n' | while read cold; do
      if [ ! -z $cold ]; then
        echo "[c]!$cold" > $list
      fi
    done

    echo $HOTLIST | tr ' ' '\n' | while read hot; do
      if [ ! -z $hot ]; then
        echo "[h]!$hot" > $list
      fi
    done

    echo "Writing new extension list..."

    cat /tmp/anykernel/f2fs-cold.list | grep -v '#' | while read cold; do
      if [ ! -z $cold ]; then
        echo "[c]$cold" > $list
      fi
    done

    cat /tmp/anykernel/f2fs-hot.list | while read hot; do
      if [ ! -z $hot ]; then
        echo "[h]$hot" > $list
      fi
    done
  done
} || ui_print 'WARNING: /data is not mounted, some tweaks will be missing!'
# end ramdisk changes

ui_print "Installing new boot image..."
write_boot;

## end install
ui_print "Done!"
