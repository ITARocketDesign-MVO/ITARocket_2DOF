
#tudo que precisar ser testado, fazer nessa pasta
include("../src/Rocket_2DOF.jl")
using .Rocket_2DOF
#criação de condições iniciais:


X₀, rocket, env = manual_input(
    empty_mass = 27.0,
    rocket_cd = read_cd(project = "Montenegro-1"),
    rocket_area = pi*(0.079)^2,
    thrust = read_thrust(project = "Montenegro-1"),
    propellant_mass = 4.56,
    burn_time = 6.74,
    airbreak_cd = 0.5,               #airbreak == foguete (valores de cd e area iguais)
    airbreak_area = 2*pi*(0.079)^2,
    drogue_cd = 1.5,
    drogue_area = 0.7,
    main_cd = 1.5,
    main_area = 4,
    launch_angle = 85,
    launch_altitude = 645,
    rail_length = 5
)

# Voo
allX = fullFlight(X₀, rocket, env)
text_output(allX)
# height_time(allX)
# height_horizontal(allX)
# speed_time(allX)
# accel_time(allX)
