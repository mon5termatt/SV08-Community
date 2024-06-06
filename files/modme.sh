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

    # Process each block
    for old_block in "${!BLOCKS[@]}"; do
        new_block="${BLOCKS[$old_block]}"

        # Escape special characters for sed
        old_block_escaped=$(echo "$old_block" | sed 's/[\/&]/\\&/g')
        new_block_escaped=$(echo "$new_block" | sed 's/[\/&]/\\&/g')

        # Comment out the old block and add the new block
        awk -v old_block="$old_block" -v new_block="$new_block" '
        BEGIN { split(old_block, old_lines, "\n"); split(new_block, new_lines, "\n") }
        {
            if (found) {
                if ($0 == old_lines[block_line]) {
                    print "# " $0
                    block_line++
                    if (block_line > length(old_lines)) {
                        found = 0
                        for (i in new_lines) print new_lines[i]
                    }
                } else {
                    for (i = 1; i <= block_line; i++) print "# " old_lines[i]
                    found = 0
                    print
                }
            } else if ($0 == old_lines[1]) {
                found = 1
                block_line = 1
                print "# " $0
            } else {
                print
            }
        }' "$file_path" > "$file_path.tmp"

        mv "$file_path.tmp" "$file_path"
    done

    echo "Processed $file_path and created a backup at $file_path.bak"
}

# Iterate through the files and process them
for dir in "${!FILES[@]}"; do
    file="${FILES[$dir]}"
    process_file "$dir/$file"
done

echo "All specified blocks have been commented out and replaced in the respective files."
