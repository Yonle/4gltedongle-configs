This is basically the config in the Linux system that i put onto my 4G LTE dongle.

Some changes includes:
1. adjust power mode on some hardware components, especially wifi & modem
2. set anything going out of the WWAN to be 65, effectively bypassed tether.
3. enable watchdog0 because the base didn't do it

the normal logic such as NAT is still intact.

## dependencies
1. dnsmasq (DHCP+dns)
2. Adguard `dnsproxy`
3. `hostapd`
4. NetworkManager+ModemManager
5. `irqbalance`
