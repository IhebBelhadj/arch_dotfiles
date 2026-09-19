#!/usr/bin/env bash
# Wi-Fi picker for waybar's network module. Follows HyDE's rofi conventions.

# Toggle: a second click closes the open menu instead of stacking one.
pkill -u "$USER" -x rofi && exit 0

# shellcheck source=/dev/null
[ -f "$HOME/.local/lib/hyde/globalcontrol.sh" ] && . "$HOME/.local/lib/hyde/globalcontrol.sh"

setup_rofi_config() {
    local font_scale=${ROFI_WIFI_SCALE:-${ROFI_SCALE:-10}}
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=10
    local font_name=${ROFI_WIFI_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT" 2>/dev/null)}
    font_name=${font_name:-$(get_hyprConf "FONT" 2>/dev/null)}
    font_override="* {font: \"${font_name:-JetBrainsMono Nerd Font} $font_scale\";}"

    local hypr_border=${hypr_border:-$(hyprctl -j getoption decoration:rounding | jq '.int')}
    local hypr_width=${hypr_width:-$(hyprctl -j getoption general:border_size | jq '.int')}
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;}wallbox{border-radius:${elem_border}px;}element{border-radius:${elem_border}px;}"
    rofi_position=$(get_rofi_pos 2>/dev/null)
}

run_rofi() {
    rofi -dmenu -i -markup-rows \
        -theme-str "entry { placeholder: \"$1\";}" \
        -theme-str "$font_override" \
        -theme-str "$r_override" \
        -theme-str "$rofi_position" \
        ${wifi_style:+-theme "$wifi_style"} \
        "${@:2}"
}

signal_icon() {
    local s=${1:-0}
    if   [ "$s" -ge 75 ]; then printf ''
    elif [ "$s" -ge 50 ]; then printf ''
    elif [ "$s" -ge 25 ]; then printf ''
    else                       printf ''
    fi
}

setup_rofi_config
wifi_style="$HOME/.local/share/rofi/themes/selector.rasi"
[ -f "$wifi_style" ] || wifi_style=""

radio=$(nmcli radio wifi)
if [ "$radio" != "enabled" ]; then
    choice=$(printf '  Turn Wi-Fi on' | run_rofi "Wi-Fi is off")
    [ -n "$choice" ] && nmcli radio wifi on && notify-send -a "Wi-Fi" "Radio enabled"
    exit 0
fi

notify-send -a "Wi-Fi" "Scanning..." -t 1500
nmcli device wifi rescan >/dev/null 2>&1

current=$(nmcli -t -f ACTIVE,SSID device wifi list 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')

# TAB-separated: icon+label for display, raw SSID in column 2 for the action.
list=$(nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null |
    awk -F: '$2 != "" && !seen[$2]++ {print $1"\t"$2"\t"$3"\t"$4}' |
    sort -t$'\t' -k3,3nr |
    while IFS=$'\t' read -r active ssid signal sec; do
        icon=$(signal_icon "$signal")
        lock=""; [ -n "$sec" ] && [ "$sec" != "--" ] && lock=" "
        mark=""; [ "$active" = "yes" ] && mark=" <b>(connected)</b>"
        printf "%b  %s  <small>%s%%</small>%b%b\t%s\n" \
            "$icon" "$ssid" "$signal" "$lock" "$mark" "$ssid"
    done)

menu="$list
  Rescan\t__rescan__
  Turn Wi-Fi off\t__off__
  Network settings\t__settings__"

sel=$(printf '%b' "$menu" | run_rofi "${current:-Not connected}" -display-columns 1)
[ -z "$sel" ] && exit 0

target=$(printf '%s' "$sel" | awk -F'\t' '{print $2}')
[ -z "$target" ] && exit 0

case "$target" in
__rescan__)   exec "$0" ;;
__off__)      nmcli radio wifi off && notify-send -a "Wi-Fi" "Radio disabled"; exit 0 ;;
__settings__) setsid nm-connection-editor >/dev/null 2>&1 & exit 0 ;;
esac

[ "$target" = "$current" ] && exit 0

# A stored profile reconnects without asking for the password again.
if nmcli -t -f NAME connection show | grep -Fxq "$target"; then
    if nmcli connection up id "$target" >/dev/null 2>&1; then
        notify-send -a "Wi-Fi" "Connected to $target"; exit 0
    fi
fi

secured=$(nmcli -t -f SSID,SECURITY device wifi list | awk -F: -v s="$target" '$1==s{print $2; exit}')
if [ -n "$secured" ] && [ "$secured" != "--" ]; then
    pass=$(printf '' | run_rofi "Password for $target" -password)
    [ -z "$pass" ] && exit 0
    out=$(nmcli device wifi connect "$target" password "$pass" 2>&1)
else
    out=$(nmcli device wifi connect "$target" 2>&1)
fi

if [ $? -eq 0 ]; then
    notify-send -a "Wi-Fi" "Connected to $target"
else
    notify-send -a "Wi-Fi" -u critical "Failed to connect to $target" "$out"
fi
