include("../Rocket_2DOF.jl")

using .Rocket_2DOF
using BenchmarkTools
using Plots
gr()

function f(t::Float64, X::StateVector)
    return StateVector(cos(t), -sin(t), -sin(t), -cos(t), X.m_comb)
end

all_X1 = rk4solution((0, 7), StateVector(0,1,1,0,1), f, 0.001)
all_X2 = rk4flight(StateVector(0,1,1,0,1), f)

plot1 = scatter!([(X.x, X.y) for X in all_X1])
plot()
plot2 = scatter!([(X.x, X.y) for X in all_X2])

res1 = @benchmark rk4solution((0, 7), StateVector(0,1,1,0,1), f, 0.001)
res2 = @benchmark rk4flight(StateVector(0,1,1,0,1), f)
