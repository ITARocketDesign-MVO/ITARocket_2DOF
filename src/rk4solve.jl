module Solver
using ..BaseDefinitions
export fullFlight

function Xdot(t::Real, X::StateVector, rocket::Rocket, env::Environment, phase::Int)
    acc = rocket.flight_phases[phase].dynamic(t, X, rocket, env)
    return StateVector(X.vx, X.vy, acc[1], acc[2])
end

"""
    rk4solver(t::Real, X::StateVector, rocket::Rocket,
              env::Environment, phase::Int, dt::Float64)

Solver em método de Runge-Kutta de 4a ordem

Calcula o próximo passo no tempo para o foguete (_rocket_) com base na dinamica
da fase de seu voo (_rocket.flightphases[phase].name_) e do ambiente em que se
ele encontra (_env_)

> X_{t + dt} = X_{t} + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)
"""
function rk4solver(t::Real, X::StateVector, rocket::Rocket,
                   env::Environment, phase::Int, dt::Float64)

    k1 = Xdot(     t    ,         X       , rocket, env, phase)
    k2 = Xdot(t + dt / 2, X + (dt / 2) *k1, rocket, env, phase)
    k3 = Xdot(t + dt / 2, X + (dt / 2) *k2, rocket, env, phase)
    k4 = Xdot(  t + dt  ,      X + k3     , rocket, env, phase)

    return X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

"""
    solveStage(t::Real, X0::StateVector, rocket::Rocket,
               env::Environment, phase::Int, dt::Float64)

Descreve a trajetória do foguete durante toda uma fase
utilizando a função rk4solve
"""
function solveStage(t::Real, X0::StateVector, rocket::Rocket,
                    env::Environment, phase::Int, dt::Float64)

    # Praticamente toda a memoria que a funcao aloca ta aqui
    all_Xs = Vector{Any}(undef, Int64(1000 / dt))
    all_Xs[1] = X0
    j = 2

    # Enquanto a condição de troca de fase não for cumprida, continue
    while !rocket.flight_phases[phase].end_condition(t, all_Xs[j - 1],
                                                           rocket, env)

        # Realização do passo com o solver rk4
        all_Xs[j] = rk4solver(t, all_Xs[j - 1], rocket, env, phase, dt)

        # Pra n ficar infinito, significa que alguma condicao eh incoerente
        if all_Xs[j].y == Inf
            return
        end

        # Preparo para o próximo passo
        j += 1
        t += dt
    end

    # Todas as posições percorridas pelo foguete e o momento que a fase termina
    return all_Xs[1:j - 1], t - dt
end


"""
    fullFlight(X0::StateVector, rocket::Rocket,
               env::Environment, dt::Float64=0.001)

Descreve a trajetória do foguete durante todo o voo, passando por todas
as fases definidas em _rocket.flightphases_
"""
function fullFlight(X0::StateVector, rocket::Rocket,
                    env::Environment, dt::Float64=0.001)

    phase = 1
    full_Flight = Dict{Any, Any}()
    transition_state = X0
    t = 0.0

    while true

        # Armazena a trajetoria e momento final de uma fase do voo
        all_Xs, t = solveStage(t, transition_state, rocket, env, phase, dt)
        full_Flight[rocket.flight_phases[phase].name] = (all_Xs, t)

        # Condicao inicial da proxima fase do voo
        transition_state = all_Xs[end]

        # Vetor de fases percorrido, finalizacao
        if phase == length(rocket.flight_phases)
            full_Flight["end"] = Vector{Any}(undef, 1)
            full_Flight["end"][1] = all_Xs[end]
            return full_Flight
        end

        # Proxima fase do voo
        phase += 1
    end
end

end