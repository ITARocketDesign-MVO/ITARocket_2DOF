#tudo que precisar ser testado, fazer nessa pasta
include("../base_def.jl")

include("../input.jl")
using .Inputs
#criação de condições iniciais:

X₀, rocket, env = manual_input(
    empty_mass = 23.5,
    rocket_cd = 0.4,
    rocket_area = 0.08,
    thrust = 2000,
    propellant_mass = 4.5,
    burn_time = 6.74,
    drogue_cd = 1.5,
    drogue_area = 0.7,
    main_cd = 1.5,
    main_area = 4,
    launch_angle = 85,
    launch_altitude = 1294,
    rail_length = 5
)
