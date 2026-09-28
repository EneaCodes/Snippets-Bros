#!/usr/bin/env bash
set -euo pipefail

SOURCE_REPO="https://github.com/Boilerplate4u/openwrt.git"
SOURCE_COMMIT="fa97b1e47dcb52649cded03c60d4c93a98b0d2ee"
WORKDIR="${PWD}/openwrt"

git clone --filter=blob:none "${SOURCE_REPO}" "${WORKDIR}"
cd "${WORKDIR}"
git fetch origin "${SOURCE_COMMIT}" --depth=1
git checkout --detach "${SOURCE_COMMIT}"

./scripts/feeds update -a
./scripts/feeds install -a

mkdir -p files/usr/sbin files/etc/config files/etc/init.d files/etc/hotplug.d/net files/etc/uci-defaults

cat > files/usr/sbin/clientlimit <<'EOF'
#!/bin/sh
. /lib/functions.sh

CFG=clientlimit

load_cfg() {
    config_load "$CFG"
    config_get mode main mode limit
    config_get mac main mac "BE:8E:8B:10:9B:62"
    config_get down main down_mbit 5
    config_get up main up_mbit 1
}

wifi_ifaces() {
    for p in /sys/class/net/*; do
        [ -e "$p/phy80211" ] || continue
        basename "$p"
    done
}

clear_dev() {
    dev="$1"
    tc qdisc del dev "$dev" root 2>/dev/null || true
    tc qdisc del dev "$dev" ingress 2>/dev/null || true
}

apply_limit() {
    dev="$1"
    tc qdisc replace dev "$dev" root handle 1: htb default 1
    tc class replace dev "$dev" parent 1: classid 1:1 htb rate 1000mbit ceil 1000mbit
    tc class replace dev "$dev" parent 1:1 classid 1:10 htb rate "${down}mbit" ceil "${down}mbit"
    tc filter replace dev "$dev" protocol all parent 1: prio 10 flower dst_mac "$mac" classid 1:10

    tc qdisc replace dev "$dev" handle ffff: ingress
    tc filter replace dev "$dev" parent ffff: protocol all prio 10 flower src_mac "$mac" \
        action police rate "${up}mbit" burst 128k conform-exceed drop
}

apply_block() {
    dev="$1"
    tc qdisc replace dev "$dev" root handle 1: htb default 1
    tc class replace dev "$dev" parent 1: classid 1:1 htb rate 1000mbit ceil 1000mbit
    tc filter replace dev "$dev" protocol all parent 1: prio 1 flower dst_mac "$mac" action drop

    tc qdisc replace dev "$dev" handle ffff: ingress
    tc filter replace dev "$dev" parent ffff: protocol all prio 1 flower src_mac "$mac" action drop
}

apply_all() {
    load_cfg
    found=0
    for dev in $(wifi_ifaces); do
        found=1
        clear_dev "$dev"
        case "$mode" in
            limit) apply_limit "$dev" ;;
            block) apply_block "$dev" ;;
            off) : ;;
            *) echo "Unknown mode: $mode" >&2; exit 1 ;;
        esac
    done
    [ "$found" -eq 1 ] || echo "No Wi-Fi interfaces are up yet; rules will be applied by hotplug when Wi-Fi starts."
}

save() {
    uci -q batch <<EOFUCI
set clientlimit.main=client
set clientlimit.main.mode='$1'
set clientlimit.main.mac='$2'
set clientlimit.main.down_mbit='$3'
set clientlimit.main.up_mbit='$4'
commit clientlimit
EOFUCI
}

cmd="${1:-status}"
load_cfg

case "$cmd" in
    set)
        new_down="${2:-5}"
        new_up="${3:-1}"
        new_mac="${4:-$mac}"
        save limit "$new_mac" "$new_down" "$new_up"
        apply_all
        echo "LIMITED $new_mac: ${new_down} Mbps download / ${new_up} Mbps upload"
        ;;
    block)
        save block "$mac" "$down" "$up"
        apply_all
        echo "BLOCKED $mac"
        ;;
    unblock)
        save limit "$mac" "$down" "$up"
        apply_all
        echo "UNBLOCKED $mac; limiter restored to ${down}/${up} Mbps"
        ;;
    off)
        save off "$mac" "$down" "$up"
        apply_all
        echo "Limiter OFF"
        ;;
    apply)
        apply_all
        ;;
    status)
        echo "Mode: $mode"
        echo "MAC: $mac"
        echo "Download limit: $down Mbps"
        echo "Upload limit: $up Mbps"
        echo
        for dev in $(wifi_ifaces); do
            echo "=== $dev ==="
            tc -s qdisc show dev "$dev" 2>/dev/null || true
            tc -s filter show dev "$dev" parent 1: 2>/dev/null || true
            tc -s filter show dev "$dev" ingress 2>/dev/null || true
        done
        ;;
    *)
        echo "Usage:"
        echo "  clientlimit status"
        echo "  clientlimit set <down_mbit> <up_mbit> [MAC]"
        echo "  clientlimit block"
        echo "  clientlimit unblock"
        echo "  clientlimit off"
        echo "  clientlimit apply"
        exit 2
        ;;
esac
EOF
chmod 0755 files/usr/sbin/clientlimit

cat > files/etc/config/clientlimit <<'EOF'
config client 'main'
    option mode 'limit'
    option mac 'BE:8E:8B:10:9B:62'
    option down_mbit '5'
    option up_mbit '1'
EOF

cat > files/etc/init.d/clientlimit <<'EOF'
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /bin/sh -c 'sleep 12; /usr/sbin/clientlimit apply'
    procd_set_param respawn 3600 5 0
    procd_close_instance
}
EOF
chmod 0755 files/etc/init.d/clientlimit

cat > files/etc/hotplug.d/net/99-clientlimit <<'EOF'
#!/bin/sh
case "$ACTION" in
    add|ifup)
        ( sleep 3; /usr/sbin/clientlimit apply >/dev/null 2>&1 ) &
        ;;
esac
EOF
chmod 0755 files/etc/hotplug.d/net/99-clientlimit

cat > files/etc/uci-defaults/99-dap1620-custom <<'EOF'
#!/bin/sh

uci -q set system.@system[0].hostname='DAP1620-Custom'

uci -q set network.lan.proto='static'
uci -q set network.lan.ipaddr='192.168.1.187'
uci -q set network.lan.netmask='255.255.255.0'
uci -q set network.lan.gateway='192.168.1.1'
uci -q add_list network.lan.dns='192.168.1.1'

uci -q set dhcp.lan.ignore='1'

uci -q batch <<'EOFUCI'
add luci command
set luci.@command[-1].name='Client limiter: status'
set luci.@command[-1].description='Show the current DAP-1620 per-client limiter and traffic-control counters.'
set luci.@command[-1].command='/usr/sbin/clientlimit status'
set luci.@command[-1].param='0'
set luci.@command[-1].public='0'

add luci command
set luci.@command[-1].name='Client limiter: 5 Mbps down / 1 Mbps up'
set luci.@command[-1].description='Limit BE:8E:8B:10:9B:62 to 5 Mbps download and 1 Mbps upload.'
set luci.@command[-1].command='/usr/sbin/clientlimit set 5 1 BE:8E:8B:10:9B:62'
set luci.@command[-1].param='0'
set luci.@command[-1].public='0'

add luci command
set luci.@command[-1].name='Client limiter: BLOCK'
set luci.@command[-1].description='Block BE:8E:8B:10:9B:62 on the DAP-1620 Wi-Fi.'
set luci.@command[-1].command='/usr/sbin/clientlimit block'
set luci.@command[-1].param='0'
set luci.@command[-1].public='0'

add luci command
set luci.@command[-1].name='Client limiter: UNBLOCK'
set luci.@command[-1].description='Unblock the client and restore the configured bandwidth limit.'
set luci.@command[-1].command='/usr/sbin/clientlimit unblock'
set luci.@command[-1].param='0'
set luci.@command[-1].public='0'

add luci command
set luci.@command[-1].name='Client limiter: OFF'
set luci.@command[-1].description='Remove all client-limit traffic-control rules.'
set luci.@command[-1].command='/usr/sbin/clientlimit off'
set luci.@command[-1].param='0'
set luci.@command[-1].public='0'
EOFUCI

uci -q commit system
uci -q commit network
uci -q commit dhcp
uci -q commit luci

/etc/init.d/clientlimit enable
exit 0
EOF
chmod 0755 files/etc/uci-defaults/99-dap1620-custom

cat > .config <<'EOF'
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7620=y
CONFIG_TARGET_ramips_mt7620_DEVICE_dlink_dap-1620-a2=y

CONFIG_PACKAGE_luci-light=y
CONFIG_PACKAGE_luci-app-commands=y

CONFIG_PACKAGE_tc-tiny=y
CONFIG_PACKAGE_kmod-sched-core=y
CONFIG_PACKAGE_kmod-sched-flower=y
CONFIG_PACKAGE_kmod-sched-act-police=y

# CONFIG_PACKAGE_ppp is not set
# CONFIG_PACKAGE_kmod-ppp is not set
# CONFIG_PACKAGE_ppp-mod-pppoe is not set
# CONFIG_PACKAGE_kmod-pppoe is not set
# CONFIG_PACKAGE_kmod-pppox is not set
# CONFIG_PACKAGE_kmod-slhc is not set
# CONFIG_PACKAGE_luci-proto-ppp is not set
EOF

make defconfig

echo "=== Effective target/package config ==="
grep -E 'CONFIG_TARGET_ramips|CONFIG_PACKAGE_(luci-light|luci-app-commands|tc-tiny|kmod-sched)' .config || true

make download -j"$(nproc)"
make -j"$(nproc)" V=s

OUT="bin/targets/ramips/mt7620"
SYS="$(find "$OUT" -maxdepth 1 -type f -name '*dlink_dap-1620-a2*squashfs-sysupgrade.bin' -print -quit)"
RAM="$(find "$OUT" -maxdepth 1 -type f -name '*dlink_dap-1620-a2*initramfs-kernel.bin' -print -quit)"

[ -n "$SYS" ] && [ -f "$SYS" ] || { echo "ERROR: sysupgrade image not found"; find "$OUT" -maxdepth 1 -type f -printf '%f %s bytes\n' || true; exit 1; }
[ -n "$RAM" ] && [ -f "$RAM" ] || { echo "ERROR: initramfs image not found"; find "$OUT" -maxdepth 1 -type f -printf '%f %s bytes\n' || true; exit 1; }

LIMIT=8060928
SYSSIZE="$(stat -c%s "$SYS")"
if [ "$SYSSIZE" -gt "$LIMIT" ]; then
    echo "ERROR: sysupgrade is $SYSSIZE bytes, over firmware limit $LIMIT"
    exit 1
fi

mkdir -p ../artifact
cp "$SYS" ../artifact/
cp "$RAM" ../artifact/
cp "$OUT/sha256sums" ../artifact/ 2>/dev/null || true

{
    echo "D-Link DAP-1620 A2 custom OpenWrt development build"
    echo "Source commit: $SOURCE_COMMIT"
    echo "Firmware partition limit: $LIMIT bytes"
    echo "Sysupgrade bytes: $SYSSIZE"
    echo
    sha256sum "$SYS" "$RAM"
    echo
    echo "Default management IP: 192.168.1.187"
    echo "Main router/gateway assumed: 192.168.1.1"
    echo "DHCP server on DAP: disabled"
    echo "Initial client limiter: BE:8E:8B:10:9B:62 at 5 Mbps down / 1 Mbps up"
    echo "LuCI: System -> Custom Commands"
    echo
    echo "IMPORTANT: first installation is via serial/U-Boot/TFTP. Do NOT upload the sysupgrade image to the stock D-Link web updater."
} > ../artifact/BUILD-INFO.txt

ls -lh ../artifact
cat ../artifact/BUILD-INFO.txt
