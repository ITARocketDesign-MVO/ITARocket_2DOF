#tudo que precisar ser testado, fazer nessa pasta
using ITARocket_2DOF

## Input online
X₀, rocket, env = online_input("1TAA_Smb9670jyX4x2cwONw7SeEl74sQWG3ybIVIn5yk")

## Input manual
# X₀, rocket, env = manual_input(
#     empty_mass=27.0,
#     rocket_cd=[0.0600 1.1180
#         0.0900 1.1050
#         0.1000 1.1020
#         0.2000 1.0920
#         0.3000 1.1010
#         0.3500 1.1100
#         0.4000 1.1230
#         0.6000 1.2230
#         0.7000 1.3690
#         0.8000 1.5650
#         0.9500 1.8820
#         1.1000 2.6000],
#     rocket_area=0.01824,
#     thrust=1500,
#     propellant_mass=4.56,
#     burn_time=8.68,
#     airbrake_cd=1.5,
#     airbrake_area=0.01834,
#     drogue_cd=1.03,
#     drogue_area=0.4144,
#     main_cd=2.66,
#     main_area=4,
#     launch_angle=86,
#     launch_altitude=645,
#     rail_length=5.7,
#     airbrake_option="noairbrake",
#     airbrake_opening_logic=(t, X, rocket, env) -> (X.y >= -7.9528299946541585 * X.vy + 3403.5517928697045),
#     nozzle_area=0.00514
# )

## Input por arquivo
# X₀, rocket, env = read_project("Montenegro-1")

## Voo
allX = simulate(X₀, rocket, env)

## Outputs
# text_output(allX)
# height_time(allX)
# height_horizontal(allX)
# speed_time(allX)
# accel_time(allX)