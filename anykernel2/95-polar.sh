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

# Reduce kswapd cpu usage
echo 85 > /proc/sys/vm/swappiness

# Marginally reduce suspend latency
echo 1 > /sys/module/printk/parameters/console_suspend

# IO block tweaks for better system performance;
for i in /sys/block/*/queue; do
  echo 0 > $i/add_random;
  echo 0 > $i/iostats;
  echo 0 > $i/nomerges;
  echo 32 > $i/nr_requests;
  echo 128 > $i/read_ahead_kb;
  echo 0 > $i/rotational;
  echo 1 > $i/rq_affinity;
  echo "cfq" > $i/scheduler;
done;

# Tweak cfq IO scheduler for less latency
for i in /sys/block/*/queue/iosched; do
  echo 4 > $i/quantum;
  echo 80 > $i/fifo_expire_sync;
  echo 330 > $i/fifo_expire_async;
  echo 12582912 > $i/back_seek_max;
  echo 1 > $i/back_seek_penalty;
  echo 60 > $i/slice_sync;
  echo 50 > $i/slice_async;
  echo 2 > $i/slice_async_rq;
  echo 0 > $i/slice_idle;
  echo 0 > $i/group_idle;
  echo 1 > $i/low_latency;
  echo 300 > $i/target_latency;
done;
