include("base_def.jl")

using .BaseDefinitions

function forces_drogue(X::StateVector, t::Float64, env::Enviroment, rocket::Rocket)
    
    M = X.m_comb + rocket.empty_mass
    W = M * env.g
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)

    Drag = 0.5 * env.ρ * rocket.drogue.aed.area * M * (X.vx^2 + X.vy^2)

    Fx = -cosθ * Drag
    Fy = -sinθ * Drag - W

    return Fx, Fy 
end
