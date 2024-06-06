#!/bin/bash

# Define the directories and file paths
declare -A FILES
FILES["~/printer_data/config"]="printer.cfg"
FILES["~/klipper/klippy/extras/display"]="menu.cfg"

# Define the blocks to be commented out and their replacements
declare -A BLOCKS
BLOCKS["[output_pin main_led]
pin:PA3
pwm: 1
value:1
cycle_time: 5"]="[output_pin main_led]
pin:PA3
pwm: 1
value:1
cycle_time: 0.010"

BLOCKS["[menu __main __tune __ledonoff]
type: input
name: Led: {'ON ' if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0
input_max: 1
input_step: 1
gcode:
    SET_PIN PIN=main_led VALUE={1 if menu.input else 0}"]="[menu __main __tune __ledonoff]
type: input
enable: {'output_pin main_led' in printer}
name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0.0
input_max: 1.0
input_step: 0.01
gcode: SET_PIN PIN=main_led VALUE={menu.input}"

BLOCKS["[menu __main __control2 __ledonoff]
type: input
name: Led: {'ON ' if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0
input_max: 1
input_step: 1
gcode:
    SET_PIN PIN=main_led VALUE={1 if menu.input else 0}"]="[menu __main __control2 __ledonoff]
type: input
enable: {'output_pin main_led' in printer}
name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
input: {printer['output_pin main_led'].value}
input_min: 0.0
input_max: 1.0
input_step: 0.01
gcode: SET_PIN PIN=main_led VALUE={menu.input}"

# Function to process a file
process_file() {
    local file_path=$1

    # Expand the tilde to the home directory
    file_path="${file_path/#\~/$HOME}"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        echo "File $file_path not found!"
        return
    fi

    # Create a backup of the original file
    cp "$file_path" "$file_path.bak"

    # Read the file and process the blocks
    awk -v blocks="$(declare -p BLOCKS)" '
    BEGIN {
        eval("declare -A blk=" blocks)
        for (key in blk) {
            split(key, old_lines, "\n")
            split(blk[key], new_lines, "\n")
            block_data[key]["old"] = old_lines
            block_data[key]["new"] = new_lines
        }
    }
    {
        found = 0
        for (key in block_data) {
            old_lines = block_data[key]["old"]
            new_lines = block_data[key]["new"]
            if ($0 == old_lines[1]) {
                match = 1
                for (i = 2; i <= length(old_lines); i++) {
                    getline next_line
                    if (next_line != old_lines[i]) {
                        match = 0
                        break
                    }
                }
                if (match) {
                    for (i = 1; i <= length(old_lines); i++) {
                        print "# " old_lines[i]
                    }
                    for (i = 1; i <= length(new_lines); i++) {
                        print new_lines[i]
                    }
                    found = 1
                    break
                }
            }
        }
        if (!found) {
            print
        }
    }' "$file_path" > "$file_path.tmp"

    # Move the temporary file to the original file
    mv "$file_path.tmp" "$file_path"
    echo "Processed $file_path and created a backup at $file_path.bak"
}

# Iterate through the files and process them
for dir in "${!FILES[@]}"; do
    file="${FILES[$dir]}"
    process_file "$dir/$file"
done

echo "All specified blocks have been commented out and replaced in the respective files."
