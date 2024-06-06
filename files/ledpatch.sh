#!/bin/bash

# Define the file paths with full paths
printer_cfg="/home/sovol/printer_data/config/printer.cfg"
menu_cfg="/home/sovol/klipper/klippy/extras/display/menu.cfg"

# Define the lines to be replaced in printer.cfg
old_line="cycle_time: 5"
new_line="cycle_time: 0.010"

# Replace the line in printer.cfg
sed -i "/\[output_pin main_led\]/,/cycle_time: 5/ s/$old_line/$new_line/" "$printer_cfg"

# Define the old and new content for the first replacement in menu.cfg
old_content1="[menu __main __tune __ledonoff]
type: input
name: Led: {'ON ' if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0
input_max: 1
input_step: 1
gcode:
    SET_PIN PIN=main_led VALUE={1 if menu.input else 0}"

new_content1="[menu __main __tune __ledonoff]
type: input
enable: {'output_pin main_led' in printer}
name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0.0
input_max: 1.0
input_step: 0.01
gcode: SET_PIN PIN=main_led VALUE={menu.input}"

# Create a temporary file to store modified content for the first replacement
temp_file1=$(mktemp)

# Remove the old content and insert the new content for the first replacement
sed "/\[menu __main __tune __ledonoff\]/,/\[menu __main __tune __save\]/{ /\[menu __main __tune __save\]/!d }" "$menu_cfg" > "$temp_file1"
echo "$new_content1" >> "$temp_file1"

# Replace the original file with the modified content for the first replacement
mv "$temp_file1" "$menu_cfg"

# Define the old and new content for the second replacement in menu.cfg
old_content2="[menu __main __control2 __ledonoff]
type: input
name: Led: {'ON ' if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0
input_max: 1
input_step: 1
gcode:
    SET_PIN PIN=main_led VALUE={1 if menu.input else 0}"

new_content2="[menu __main __control2 __ledonoff]
type: input
enable: {'output_pin main_led' in printer}
name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0.0
input_max: 1.0
input_step: 0.01
gcode: SET_PIN PIN=main_led VALUE={menu.input}"

# Create a temporary file to store modified content for the second replacement
temp_file2=$(mktemp)

# Remove the old content and insert the new content for the second replacement
sed "/\[menu __main __control2 __ledonoff\]/,/\[menu __main __tune __ledonoff\]/{ /\[menu __main __tune __ledonoff\]/!d }" "$menu_cfg" > "$temp_file2"
echo "$new_content2" >> "$temp_file2"

# Replace the original file with the modified content for the second replacement
mv "$temp_file2" "$menu_cfg"

echo "Content replaced successfully."

echo "Lines in printer.cfg replaced successfully."
echo "Content in menu.cfg replaced successfully."
