function forces_main(t::Float64, X::StateVector, rocket::Rocket, env::Environment)

    M = X.m_comb + rocket.empty_mass
    W = M * env.g
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)

    Drag = 0.5 * env.ρ * rocket.main.aed.area * M * (X.vx^2 + X.vy^2)

    Fx = -cosθ * Drag
    Fy = -sinθ * Drag - W

    return Fx, Fy
end
