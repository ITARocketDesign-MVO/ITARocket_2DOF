function forces_rail(X::StateVector, env::Environment, rocket::Rocket)
    M = X.m_comb + rocket.empty_mass #massa do foguete
    W = M * env.g #W de Weight, peso
    θ = env.rail.θ_ground

    Drag = 1/2 * env.ρ * rocket.aed.area * rocket.aed.Cd * (X.vx^2 + X.vy^2) #F(resistencia do ar)=1/2*ρ*S*Cd*v^2
    N = W * cos(θ) #Força normal
    Friction = N * env.rail.μ #Fat

    Fx = max(cos(θ) * (rocket.propulsion.thrust - Drag - Friction) - sin(θ) * N, 0)      #forças resultantes em x e em y
    Fy = max(sin(θ) * (rocket.propulsion.thrust - Drag - Friction) + cos(θ) * N - W, 0)  #há esse max para não acontecer do foguete "cair e atravessar o chão"

    return Fx, Fy
end
