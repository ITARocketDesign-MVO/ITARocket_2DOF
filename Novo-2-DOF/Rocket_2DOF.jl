module Rocket_2DOF

# Base defs
#exportar menos coisas? (só StateVector, Rkt e Amb)
export StateVector, Aed, Parachute, Propulsion, Rocket, Rail, Environment

# Runge-Kutta
# Se pa n precisa exportar o rk4solver
export rk4solver, rk4solution, rk4flight

include("base_def.jl")
include("rk4solve.jl")

end # module
