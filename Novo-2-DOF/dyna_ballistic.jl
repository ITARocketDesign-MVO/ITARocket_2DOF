using Base: Float64
include("base_def.jl")

using .BaseDefinitions

function forces_ballistic(X::StateVector, t::Float64, env::Enviroment, rocket::Rocket)
    
    M = X.m_comb + rocket.empty_mass
    W = M * env.g
    cos(θ) = X.vx/sqrt(X.vx^2 + X.vy^2)
    sin(θ) = X.vy/sqrt(X.vx^2 + X.vy^2)

    Drag = 0.5 * env.ρ * rocket.aed.area * rocket.aed.Cd * M * (X.vx^2 + X.vy^2)

    Fx = abs(cos(θ)) * (Rocket.propulsion.thrust - Drag)
    Fy = abs(sin(θ)) * (Rocket.propulsion.thrust - Drag) + W
    
    return Fx, Fy
end