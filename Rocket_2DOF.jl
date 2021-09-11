module Rocket_2DOF
include("base_def.jl")
include("input.jl")
include("rk4solve.jl")
using .Inputs, .Solver

export manual_input, fullFlight
end
