module Dynamics
using ...BaseDefinitions
#temporário
#copiar código das funções para cá
export forces_rail, forces_thrusted, forces_ballistic, forces_drogue, forces_main
include("rail_dynamic.jl")
function forces_thrusted(t::Float64, x::StateVector, rocket::Rocket, env::Environment)
    [
        0.0
        0.0
    ]
end
include("dyna_ballistic.jl")
include("dyna_drogue.jl")
include("dyna_main.jl")
end