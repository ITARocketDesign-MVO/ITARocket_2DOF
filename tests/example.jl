
#tudo que precisar ser testado, fazer nessa pasta
include("../src/Rocket_2DOF.jl")
using .Rocket_2DOF
#criação de condições iniciais:

Leithrust("Montenegro-1")

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


# Voo
all_X = fullFlight(X₀, rocket, env)

x1=[Element.x for Element in all_X["rail"][1]]
x2=[Element.x for Element in all_X["thrusted"][1]]
x3=[Element.x for Element in all_X["ballistic"][1]]
x4=[Element.x for Element in all_X["drogue"][1]]
x5=[Element.x for Element in all_X["main"][1]]
x=vcat(x1, x2, x3, x4, x5)

y1=[Element.y for Element in all_X["rail"][1]]
y2=[Element.y for Element in all_X["thrusted"][1]]
y3=[Element.y for Element in all_X["ballistic"][1]]
y4=[Element.y for Element in all_X["drogue"][1]]
y5=[Element.y for Element in all_X["main"][1]]
y=vcat(y1, y2, y3, y4, y5)

vx1=[Element.vx for Element in all_X["rail"][1]]
vx2=[Element.vx for Element in all_X["thrusted"][1]]
vx3=[Element.vx for Element in all_X["ballistic"][1]]
vx4=[Element.vx for Element in all_X["drogue"][1]]
vx5=[Element.vx for Element in all_X["main"][1]]
vx=vcat(vx1, vx2, vx3, vx4, vx5)

vy1=[Element.vy for Element in all_X["rail"][1]]
vy2=[Element.vy for Element in all_X["thrusted"][1]]
vy3=[Element.vy for Element in all_X["ballistic"][1]]
vy4=[Element.vy for Element in all_X["drogue"][1]]
vy5=[Element.vy for Element in all_X["main"][1]]
vy=vcat(vy1, vy2, vy3, vy4, vy5)

v=(vx.^2+vy.^2).^(1/2)

using Plots
theme(:dark)

plot(x, y,
title = "Trajetória",
xlabel = "x(m)",
ylabel = "y(m)",)

