#!/bin/bash
#
# quickcmds.1h.sh — xbar plugin: one-click terminal command buttons in the menu bar.
#
# INSTALL:
#   1. Install xbar:  https://xbarapp.com  (or `brew install --cask xbar`)
#   2. Launch xbar once — it will ask you to pick a plugin folder (e.g. ~/xbar-plugins)
#   3. Copy this file into that folder
#   4. Make it executable:  chmod +x quickcmds.1h.sh
#   5. Click "Refresh All" in the xbar menu (or wait ~1hr, per the ".1h." in the filename)
#
# The ".1h." in the filename tells xbar to refresh this menu every hour.
# Rename to ".5s." for every 5 seconds, ".30m." for 30 min, etc.
#
# Anything printed before the line "---" becomes the menu bar icon/title.
# Anything after "---" becomes the dropdown menu.
# Each line becomes a clickable item using xbar's param syntax:
#   Label | bash=/path param1=arg1 param2=arg2 terminal=false
#
# CUSTOM COMMANDS LIST — edit this array to add your own one-click buttons.
# Each entry: "Label|||command to run"
# Use |||  as the separator between label and command.
# NOTE: Avoid quotes in commands. Use simple shell commands or scripts.
CUSTOM_COMMANDS=(
  "Flush DNS Cache|||sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
  "Restart Finder|||killall Finder"
  "Restart Dock|||killall Dock"
  "Empty Trash|||rm -rf ~/.Trash/*"
)

echo "⚡"
echo "---"

echo "Restart Bluetooth | bash='$0' param1=run_bluetooth terminal=false refresh=true"
echo "---"

# Render each custom command as its own clickable menu item
for entry in "${CUSTOM_COMMANDS[@]}"; do
  label="${entry%%|||*}"
  cmd="${entry#*|||}"
  # Pass the actual command as an argument to this same script
  echo "${label} | bash='$0' param1=run_custom param2=\"${cmd}\" terminal=false refresh=true"
done

echo "---"
echo "Add / Run a One-Off Command… | bash='$0' param1=run_prompt terminal=false refresh=true"
echo "Edit This Plugin… | bash='open -e $0' terminal=false"

# ---- Handler section: xbar re-invokes this same script with params when clicked ----

if [ "$1" = "run_bluetooth" ]; then
  osascript -e 'do shell script "pkill bluetoothd" with administrator privileges with prompt "Restart Bluetooth"'
  osascript -e 'display notification "Bluetooth restarted" with title "Quick Commands"'
  exit 0
fi

if [ "$1" = "run_custom" ]; then
  cmd="$2"
  # Run with admin rights if the command itself starts with sudo, else run as-is
  if [[ "$cmd" == sudo\ * ]]; then
    stripped="${cmd#sudo }"
    osascript -e "do shell script \"$stripped\" with administrator privileges with prompt \"Quick Commands\""
  else
    eval "$cmd"
  fi
  osascript -e 'display notification "Command finished" with title "Quick Commands"'
  exit 0
fi

if [ "$1" = "run_prompt" ]; then
  input=$(osascript -e 'text returned of (display dialog "Enter a shell command to run:" default answer "" with title "Quick Commands")' 2>/dev/null)
  [ -z "$input" ] && exit 0
  if [[ "$input" == sudo\ * ]]; then
    stripped="${input#sudo }"
    osascript -e "do shell script \"$stripped\" with administrator privileges with prompt \"Quick Commands\""
  else
    eval "$input"
  fi
  osascript -e 'display notification "Command finished" with title "Quick Commands"'
  exit 0
fi
