# Fixing The LED's

> [!NOTE]
> THESE CHANGES HAVE BEEN IMPLEMENTED IN THE CODE SECTION OF THIS REPO.

By default sovol broke their implementation of dimming the LED bar on the top of the printer.<br>When you have it set to a cycle time of 5 seconds it just doesnt work well.


> /home/sovol/printer_data/config/printer.cfg

    [output_pin main_led]
    pin:PA3
    pwm: 1
    value:1
    cycle_time: 0.010










# Fixing the menu. 
#### No longer just a ON/OFF switch.

> home/sovol/klipper/klippy/extras/display/menu.cfg

    [menu __main __tune __ledonoff]
    type: input
    enable: {'output_pin main_led' in printer}
    name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
    input: {printer['output_pin main_led'].value}
    input_min: 0.0
    input_max: 1.0
    input_step: 0.01
    gcode: SET_PIN PIN=main_led VALUE={menu.input}

    [menu __main __control2 __ledonoff]
    type: input
    enable: {'output_pin main_led' in printer}
    name: Dim LED:    {'%3d%s' % (menu.input*100,'%') if menu.input else 'OFF'}
    input: {printer['output_pin main_led'].value}
    input_min: 0.0
    input_max: 1.0
    input_step: 0.01
    gcode: SET_PIN PIN=main_led VALUE={menu.input}

