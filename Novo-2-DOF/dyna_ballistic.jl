using Base: Float64
include("base_def.jl")

using .BaseDefinitions

function forces_ballistic(t::Float64, X::StateVector, rocket::Rocket, env::Enviroment)

    M = X.m_comb + rocket.empty_mass
    W = M * env.g
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)

    Drag = 0.5 * env.ρ * rocket.aed.area * rocket.aed.Cd * M * (X.vx^2 + X.vy^2)

    Fx = cosθ * (Rocket.propulsion.thrust - Drag)
    Fy = sinθ * (Rocket.propulsion.thrust - Drag) + W

    return Fx, Fy
end
