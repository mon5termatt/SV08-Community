# EDITED Sovol SV08 Pause Macro

    EDITED Sovol SV08 Pause Macro. No 95mm purge on filament runout & then auto unload. Does a simple -6mm retract & thats it. Comment out your old PAUSE macro (DO NOT DELETE IT!) & then paste this one above it.

### Credits to [Roar Ree on FB](https://www.facebook.com/groups/6997076173737632/permalink/7199102523534995)


```
[gcode_macro PAUSE]
rename_existing: PAUSE_BASE
variable_state: 'normal'
gcode:
    {% if printer.pause_resume.is_paused == False %}
        {% set x_park = printer['gcode_macro _global_var'].pause_park.x|float %}
        {% set y_park = printer['gcode_macro _global_var'].pause_park.y|float %}
        {% set e_restract = printer['gcode_macro _global_var'].pause_park.e|float %}
        {% set z_lift_max = printer['gcode_macro _global_var'].z_maximum_lifting_distance %}

        {% set state = params.STATE if 'filament_change' in params.STATE else 'normal' %}
        
        {action_respond_info("Pause Print!")}
        
        PAUSE_BASE
        M117 Pause Print!!!
        G91
        {% if (printer.gcode_move.position.z + 5) < z_lift_max %}
            G1 Z+5 F3000
        {% else %}
            G1 Z+{(z_lift_max - printer.gcode_move.position.z)} F3000
        {% endif %}
        G90
        {% if printer.gcode_move.position.x != x_park and
                printer.gcode_move.position.y != y_park     
        %}
            G1 X{x_park} Y{y_park} F{printer["gcode_macro _global_var"].pause_resume_travel_speed * 60}
        {% endif %}

        M104 S{printer.extruder.target}
    
        {% if state == 'normal' %}
            {% if (printer.extruder.temperature + 5 >= printer.extruder.target) and (printer.extruder.temperature >= printer.configfile.settings['extruder'].min_extrude_temp) %}
                {% if printer['filament_switch_sensor filament_sensor'].enabled == True and 
                    printer['filament_switch_sensor filament_sensor'].filament_detected == True
                %}
                    G91
                    G1 E-{e_restract} F300
                    G90
                {% elif printer['filament_switch_sensor filament_sensor'].enabled == True and 
                        printer['filament_switch_sensor filament_sensor'].filament_detected != True %}
                    G91
                    G1 E-5 F1500
                   # G1 E+95 F300
                   # G1 E-10 F1500
                   # G1 E-20 F600
                   # M400
                   # G4 P3000
                   # G1 E-50 F300 
                    G90
                {% endif %}
            {% endif %}
        {% elif state == 'filament_change' %}
            {% if (printer.extruder.temperature + 5 >= printer.extruder.target) and (printer.extruder.temperature >= printer.configfile.settings['extruder'].min_extrude_temp) %}
                G91
                G1 E+25 F300
                G1 E-10 F1500
                G1 E-20 F600
                M400
                G4 P3000
                G1 E-50 F300 
                G90
            {% endif %}
        {% endif %}
    {% endif %}