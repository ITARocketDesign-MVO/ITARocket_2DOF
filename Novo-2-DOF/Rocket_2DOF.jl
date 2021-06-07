module Rocket_2DOF

# Base defs
#exportar menos coisas? (só StateVector, Rkt e Amb)
export StateVector, Aed, Parachute, Propulsion, Rocket, Rail, Environment

export forces_rail

# Runge-Kutta
# Se pa n precisa exportar o rk4solver
export rk4solver, rk4solution

include("base_def.jl")
include("rail_dynamic")
include("rk4solve.jl")

end # module
