module Dynamics
using ...BaseDefinitions

include("Interpolators.jl")
using .Interpolators
export acc_rail, acc_thrusted, acc_ballistic, acc_drogue, acc_main

function acc_rail(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = get_current_mass(t, rocket) #massa do foguete
    θ = env.rail.θ_ground
    
    #W de Weight, peso
    W        = M * env.g(X.y+env.launch_altittude) 
    #F(resistencia do ar)=1/2*ρ*S*Cd*v^2
    Drag     = 1/2 * env.ρ(X.y+env.launch_altittude) * rocket.flight_phases[1].aed.area *
                             currentCd(X, rocket.flight_phases[1].aed.Cd, env) * (X.vx^2 + X.vy^2) 
    #Força normal
    N        = W * cosd(θ) 
    #atrito com a rampa
    Friction = N * env.rail.μ 

    #forças resultantes em x e em y
    #há esse max para não acontecer do foguete "cair e atravessar o chão"
    Fx = max(cosd(θ) * (currentThrust(t, rocket) - Drag - Friction) - sind(θ) * N, 0)
    Fy = max(sind(θ) * (currentThrust(t, rocket) - Drag - Friction) + cosd(θ) * N - W, 0)  
    
    return Fx/M, Fy/M
end

function acc_thrusted(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = get_current_mass(t, rocket)
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)

    W = M * env.g(X.y+env.launch_altittude)
    Thrust = currentThrust(t, rocket)
    Drag = 1/2 * env.ρ(X.y+env.launch_altittude) * rocket.flight_phases[2].aed.area *
                                     currentCd(X, rocket, env) * (X.vx^2 + X.vy^2)

    Fx = cosθ * (Thrust - Drag)
    Fy = sinθ * (Thrust - Drag) - W
    return Fx/M, Fy/M
end

function acc_ballistic(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = get_current_mass(t, rocket)
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)
    
    W = M * env.g(X.y+env.launch_altittude)
    Drag = 1/2 * env.ρ(X.y+env.launch_altittude) * rocket.flight_phases[3].aed.area *
                                     currentCd(X, rocket, env) * (X.vx^2 + X.vy^2)

    Fx = cosθ * ( - Drag)
    Fy = sinθ * ( - Drag) - W

    return Fx/M, Fy/M
end

function acc_drogue(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = get_current_mass(t, rocket)
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)
    
    W = M * env.g(X.y+env.launch_altittude)
    Drag = 1/2 * env.ρ(X.y+env.launch_altittude) * rocket.flight_phases[4].aed.area *
                                    rocket.flight_phases[4].aed.Cd * (X.vx^2 + X.vy^2)

    Fx = -cosθ * Drag
    Fy = -sinθ * Drag - W

    return Fx/M, Fy/M
end

function acc_main(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    M = get_current_mass(t, rocket)
    cosθ = X.vx/sqrt(X.vx^2 + X.vy^2)
    sinθ = X.vy/sqrt(X.vx^2 + X.vy^2)
    
    W = M * env.g(X.y+env.launch_altittude)
    Drag = 1/2 * env.ρ(X.y+env.launch_altittude) * rocket.flight_phases[5].aed.area * 
                                    rocket.flight_phases[5].aed.Cd * (X.vx^2 + X.vy^2)

    Fx = -cosθ * Drag
    Fy = -sinθ * Drag - W

    return Fx/M, Fy/M
end

#funções auxiliares
function get_current_mass(t::Float64, rocket::Rocket)
    return rocket.empty_mass + max((1 - t/rocket.propulsion.burn_time) *
                                         rocket.propulsion.prop_mass, 0)
end


end