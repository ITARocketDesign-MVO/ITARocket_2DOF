include("base_def.jl")

using .BaseDefinitions

function forces_rail(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = X.m_comb + rocket.empty_mass #massa do foguete
    W = M * env.g #W de Weight, peso
    θ = env.rail.θ_ground

    Drag = 1/2 * env.ρ * rocket.aed.area * rocket.aed.Cd * (X.vx^2 + X.vy^2) #F(resistencia do ar)=1/2*ρ*S*Cd*v^2
    N = W * cosd(θ) #Força normal
    Friction = N * env.rail.μ #Fat

    Fx = max(cosd(θ) * (rocket.propulsion.thrust - Drag - Friction) - sind(θ) * N, 0)      #forças resultantes em x e em y
    Fy = max(sind(θ) * (rocket.propulsion.thrust - Drag - Friction) + cosd(θ) * N - W, 0)  #há esse max para não acontecer do foguete "cair e atravessar o chão"

    return Fx, Fy
end
