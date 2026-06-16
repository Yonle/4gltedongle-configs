sleep 5

for i in /sys/class/net/*/queues/rx-0/rps_cpus; do
  echo f > "$i"
done
