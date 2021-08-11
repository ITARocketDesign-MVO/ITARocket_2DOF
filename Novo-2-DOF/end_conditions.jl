include("base_def.jl")
module EndConditions
    using ..BaseDefinitions

"""
    rail_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase da rampa terminou. Se

`` √(Δx² + Δy²) ≥ L_trilho ``,

o foguete se afastou o suficiente da rampa.
"""
function rail_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)
    return √(X.x^2+(X.y-env.launch_altittude)^2) >= env.rail.length
end

function thrusted_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)
    return t >= rocket.propulsion.burn_time
end
function ballistic_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)
    return X.vy <= 0 
end
function drogue_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)
    #parametrizar o 300? input de REC
    return X.y <= env.launch_altittude + 300
end
function main_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)
    return X.y <= 0
end
end