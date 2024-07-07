# Credits to [Roar Ree on FB](https://www.facebook.com/groups/6997076173737632/permalink/7222730737838840)
 
Here you go guys, improve your meshing & probing quality. Plus reduce your accelerations & movement speed to a more suitable level.
    
> [!NOTE]
> Acceleration values are slow safe values & should be tuned by doing resonance testing on your own machine.

> [!WARNING]
> Ammend your values & comment out the stock ones, do not delete or replace full sections with these! Elements from the stock sections are still required.


    [printer]
    kinematics: corexy           
    max_velocity: 700            
    max_accel: 8200           
    max_accel_to_decel: 4500  
    max_z_velocity: 15           
    max_z_accel: 500             
    square_corner_velocity: 5.0  

<br>

    [probe]
    speed: 5
    samples: 3
    samples_result: median
    sample_retract_dist: 5.0
    samples_tolerance: 0.0125
    samples_tolerance_retries: 10 

<br>

    [bed_mesh]
    speed: 350                
    horizontal_move_z: 5        
    probe_count: 9,9                
    algorithm: bicubic           
    bicubic_tension: 0.4
    split_delta_z:0.0125
    mesh_pps: 3,3 
    # move_check_distance: 3
    adaptive_margin: 5

<br>

    [quad_gantry_level]          
    speed: 350             
    horizontal_move_z: 5      
    retry_tolerance: 0.0125 
    retries: 5                  
    max_adjust: 10              

