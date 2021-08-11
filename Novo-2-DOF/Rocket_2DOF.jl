module Rocket_2DOF

# Base defs
#exportar menos coisas? (só StateVector, Rkt e Amb)
export StateVector, Aed, Parachute, Propulsion, Rocket, Rail, Environment

# Runge-Kutta
# Se pa n precisa exportar o rk4solver
export rk4solver, solveStage, fullFlight

include("base_def.jl")
include("rk4solve_global.jl")

end # module
