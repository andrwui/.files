
#!/usr/bin/env sh
OUT_GAPS=$(hyprctl -j getoption general:gaps_out | jq -r '.custom' | awk '{print $1}')
IN_GAPS=$(hyprctl -j getoption general:gaps_in | jq -r '.custom' | awk '{print $1}')

modifier=10

echo outer gaps $(hyprctl -j getoption general:gaps_out | jq -r '.custom')

# echo outer gaps $((OUT_GAPS + modifier))

hyprctl --batch "\
keyword general:gaps_out $((OUT_GAPS + modifier));"
