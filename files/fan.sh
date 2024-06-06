#!/bin/bash

# Define the file paths with full paths
printer_cfg="/home/sovol/printer_data/config/printer.cfg"

# Define the lines to be replaced
old_line="cycle_time: 5"
new_line="cycle_time: 0.010"

# Replace the line in printer.cfg
sed -i "/\[output_pin main_led\]/,/cycle_time: 5/ s/$old_line/$new_line/" "$printer_cfg"

# Replace the line in menu.cfg
sed -i "s/$old_line/$new_line/" "$menu_cfg"

echo "Lines replaced successfully."
