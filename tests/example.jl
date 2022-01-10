
#tudo que precisar ser testado, fazer nessa pasta
using ITARocket_2DOF
#criação de condições iniciais:


X₀, rocket, env = manual_input(
    empty_mass = 27.0,
    rocket_cd = 0.45,
    rocket_area = pi*(0.079)^2,
    thrust = 3000,
    propellant_mass = 4.56,
    burn_time = 6.74,
    airbreak_cd = 0.5,
    airbreak_area = 2*pi*(0.079)^2,
    drogue_cd = 1.5,
    drogue_area = 0.7,
    main_cd = 1.5,
    main_area = 4,
    launch_angle = 85,
    launch_altitude = 645,
    rail_length = 5
)

## Voo
allX = simulate(X₀, rocket, env)
##
text_output(allX)
height_time(allX)
height_horizontal(allX)
speed_time(allX)
accel_time(allX)
@assert length(0:allX.dt:allX.phase_transition_times[1]) == length(allX["rail"]) "Tempo incompatível na fase rail"
@assert length(allX.phase_transition_times[1]:allX.dt:allX.phase_transition_times[2]) == length(allX["thrusted"]) "Tempo incompatível na fase thrusted"
@assert length(allX.phase_transition_times[2]:allX.dt:allX.phase_transition_times[3]) == length(allX["ballistic"]) "Tempo incompatível na fase ballistic"
@assert length(allX.phase_transition_times[3]:allX.dt:allX.phase_transition_times[4]) == length(allX["airbreak"]) "Tempo incompatível na fase airbreak"
@assert length(allX.phase_transition_times[4]:allX.dt:allX.phase_transition_times[5]) == length(allX["drogue"]) "Tempo incompatível na fase drogue"
@assert length(allX.phase_transition_times[5]:allX.dt:allX.phase_transition_times[6]) == length(allX["main"]) "Tempo incompatível na fase main"

@assert all([next != prev for (next, prev) in zip(allX.state_vector_list[2:end], allX.state_vector_list[1:end-1])]) "Estados repetidos!"