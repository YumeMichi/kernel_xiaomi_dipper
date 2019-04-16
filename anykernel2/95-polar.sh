#!/system/bin/sh

#
# Wait for /data to be mounted
#

while ! mountpoint -q /data; do
  sleep 1
done

#
# Cleanup
#

# Check if Polar is no longer installed
if ! grep -q Polar /proc/version; then
  # Remove this init script
  rm -f /data/adb/service.d/95-polar.sh

  # Abort and do not apply tweaks
  exit 0
fi

#
# Wait for Android to finish booting
#

while [ "$(getprop sys.boot_completed)" != 1 ]; do
  sleep 2
done

# Wait for init to finish processing all boot_completed actions
sleep 2

#
# Apply overrides and tweaks
#

echo 85 > /proc/sys/vm/swappiness # Reduce kswapd cpu usage
echo 1 > /sys/module/printk/parameters/console_suspend # Marginally reduce suspend latency
