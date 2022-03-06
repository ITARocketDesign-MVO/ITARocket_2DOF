
#tudo que precisar ser testado, fazer nessa pasta
using ITARocket_2DOF
##criação de condições iniciais:


# X₀, rocket, env = manual_input(
#     empty_mass = 27.0,
#     rocket_cd = 0.45,
#     rocket_area = pi*(0.079)^2,
#     thrust = 3000,
#     propellant_mass = 4.56,
#     burn_time = 6.74,
#     airbrake_cd = [0 0.7
#                     0.5 1.2
#                     1.5 1.7],
#     airbrake_area = 2*pi*(0.079)^2,
#     drogue_cd = 1.5,
#     drogue_area = 0.7,
#     main_cd = 1.5,
#     main_area = 4,
#     launch_angle = 85,
#     launch_altitude = 645,
#     rail_length = 5,
#     airbrake_option = "fulllogic",
#     airbrake_opening_logic = (t, X, rocket, env) -> (X.y >= -7.9528299946541585 * X.vy + 3403.5517928697045),
#     nozzle_area = pi*(0.04)^2
# )

X₀, rocket, env = read_project("Montenegro-1")

## Voo
allX = simulate(X₀, rocket, env)
##
# text_output(allX)
# height_time(allX)
# height_horizontal(allX)
# speed_time(allX)
# accel_time(allX)