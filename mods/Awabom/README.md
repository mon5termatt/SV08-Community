# Original Link
https://github.com/awabom/3dprint/blob/main/SV08/README.md


## Sovol SV08 - Notes

These are my changes made to the SV08 config, using firmware version 2.3.3 as a starting point

### macro.cfg

#### Nozzle cleaning
I think the nozzle cleaning digs the nozzle a bit to much into the cleaning pad. Some parts were ripped off after just 2 cleaning cycles.

Under [gcode_macro CLEAN_NOZZLE]:

 * Line 64: Change "G1 Z0.2 F300" to "G1 Z1.5 F300"
 * Line 77: Change "G1 Z0.2" to "G1 Z1.5"

This will clean the nozzle higher up off the cleaning pad.

#### Z offset calibration

The z offset switch will be used at the start of every print with this change:

 * Line 304: Change "QUAD_GANTRY_LEVEL" to "_CALIBRATION_ZOFFSET". Note the beginning underscore.
 

### printer.cfg

#### Input Shaper

Under the "input_shaper" section, I manually entered the results from the 'Belt tuning' sequence. 
It seems the menu option does not save the correct 'shaper_type' setting after belt tuning. 
I also manually entered the correct frequency values here to be safe (the sovol command will save the values in the separate "saved_variables.cfg" file.

#### PID tuning

I could not see that the built-in PID tuning saved any values, so I manually entered the values in the "extruder" section (pid_kp, pid_ki, pid_kd).

### Orca Slicer profile

I used Sovols official Orca Slicer profile (from the Google Drive folder). Then made the following changes:

#### Start G-Code

 * Note 1: At the end of the start g-code, there is a section of if-statements. This adjusts the z-offset to my liking based on material.
I guess the values will differ for you.

 * Note 2: This removes the priming blob and priming lines. Instead, I use 5 skirt lines as priming in my print profiles.


	G28
	G90
	G1 X0 F9000
	G1 Y20
	G1 Z0.600 F600
	G1 Y0 F9000
	START_PRINT
	G90
	G1 X0 F9000
	G1 Y20
	G1 Z0.600 F600
	G1 Y0 F9000
	M400
	G91
	M83
	M140 S[bed_temperature_initial_layer_single] ;set bed temp
	M190 S[bed_temperature_initial_layer_single] ;wait for bed temp
	M104 S[nozzle_temperature_initial_layer] ;set extruder temp
	M109 S[nozzle_temperature_initial_layer];wait for extruder temp

	{if filament_type[initial_extruder] == "PETG"}
	SET_GCODE_OFFSET Z_ADJUST=0.15
	{elsif filament_type[initial_extruder] == "ASA"}
	SET_GCODE_OFFSET Z_ADJUST=0.10
	{elsif filament_type[initial_extruder] == "ABS"}
	SET_GCODE_OFFSET Z_ADJUST=0.10
	{elsif filament_type[initial_extruder] == "PLA"}
	SET_GCODE_OFFSET Z_ADJUST=0.10
	{else}
	SET_GCODE_OFFSET Z_ADJUST=0.15
	{endif}

	M400

#### Timelapse G-Code

	TIMELAPSE_TAKE_FRAME

(This line was removed from the 'Layer change G-Code' as in the stock profile.

#### Change Filament G-Code

	M600

#### Multimaterial tab

Checked the 'Manual Filament Change' checkbox.


#### Print Speed

Under print speed, I entered the Acceleration values I got from the belt tuning sequence. 
It mentions something about 'Don't go over X m/s2 to avoid too much smoothing'. 
I used the smaller value of those for 'Normal printing'. Travel is still 20k.
