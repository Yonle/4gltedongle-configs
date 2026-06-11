
# led
R_N='red:power'
B_N='blue:wan'
G_N='green:wlan'

# path to access
B=/sys/class/leds/

# red
R_LP=$B/$R_N
R_B=$R_LP/brightness
R_T=$R_LP/trigger

# blue
B_LP=$B/$B_N
B_B=$B_LP/brightness
B_T=$B_LP/trigger

# green
G_LP=$B/$G_N
G_B=$G_LP/brightness
G_T=$G_LP/trigger

# state
WAN_STATE=
WLAN_STATE=

# reset
echo none | tee $R_T | tee $B_T | tee $G_T
echo 0 | tee $R_B | tee $B_B | tee $G_B

wan_up() {
	[ "$WAN_STATE" != "down" ] && return
	WAN_STATE=up
	echo 0 > $R_B
	echo panic > $R_T # turn red LED off, only ON when panic
	if [ "$WLAN_STATE" == "up" ]; then
		echo phy0tx > $G_T # make green LED blink on transmit
	else
		echo usb-gadget > $G_T # make green LED blink on usb gadget activities
	fi
}

wan_down() {
	[ "$WAN_STATE" == "down" ] && return
	WAN_STATE=down
	# disable the normal trigger on red and green LED
	echo none | tee $R_T | tee $G_T
	echo timer > $R_T # make red blink
}

wlan_up() {
	[ "$WLAN_STATE" == "up" ] && return
	WLAN_STATE=up
	echo default-on > $B_T
	[ "$WAN_STATE" == "down" ] && return
	echo phy0tx > $G_T
}

wlan_down() {
	[ "$WLAN_STATE" == "down" ] && return
	WLAN_STATE=down
	echo none > $B_T
	echo 0 > $B_B
	[ "$WAN_STATE" == "down" ] && return
	echo usb-gadget > $G_T
}

check() {
	ip link show wlan0 | grep -q 'state UP' && wlan_up || wlan_down
	ip route show default dev wwan0 | grep -q . && wan_up || wan_down
}

check

while sleep 1; do check; done
