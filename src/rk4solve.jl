module Solver
using ..BaseDefinitions
export simulate

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

    Xdot = rocket.flight_phases[phase].dynamic

    k1 = StateVector(X.vx,X.vy,(Xdot(t,X,rocket,env, phase))...)
    X1 = X + (dt / 2) * k1
    k2 = StateVector(X1.vx,X1.vy,(Xdot(t+dt/2,X1,rocket,env, phase))...)
    X2 = X + (dt / 2) * k2
    k3 = StateVector(X2.vx,X2.vy,(Xdot(t+dt/2, X2,rocket,env, phase))...)
    X3 = X + dt * k3
    k4 = StateVector(X3.vx,X3.vy,(Xdot(t+dt,X3,rocket,env, phase))...)

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
    t_start = t
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
    (t_start != t) && return all_Xs[1:j - 1], t - dt
    return all_Xs[1:j - 1], t
end



"""
    simulate(X0::StateVector, rocket::Rocket,
               env::Environment, dt::Float64=0.001)

Descreve a trajetória do foguete durante todo o voo, passando por todas
as fases definidas em _rocket.flightphases_
"""
function simulate(X0::StateVector, rocket::Rocket,
                    env::Environment, dt::Float64=0.001; start_phase_index = 1, end_phase_index = Inf)

    if 1 <= start_phase_index <= length(rocket.flight_phases)
        phase_index = start_phase_index
    else
        error("Não existe uma fase de voo com índice $(start_phase_index)!\n")
    end
    transition_state = X0
    t = 0.0
    
    state_vector_list = Vector{StateVector}()
    phase_transition_times = Vector{Float64}()
    phase_names = Vector{String}()

    while true

        # Resolve uma fase do voo
        Xs, t_end = solveStage(t, transition_state, rocket, env, phase_index, dt)
        
        # Armazena as informações necessarias
        push!(state_vector_list, Xs...)
        push!(phase_transition_times, t_end)
        push!(phase_names, rocket.flight_phases[phase_index].name)

        # Condicao inicial da proxima fase do voo
        transition_state = Xs[end]

        # Vetor de fases percorrido, finalizacao
        if phase_index == length(rocket.flight_phases) || phase_index == end_phase_index
            return SimResults(dt, state_vector_list, phase_transition_times, phase_names)
        end

        # Proxima fase do voo
        #if(phase == 2) phase += 1 end

        phase_index += 1
        t = t_end
    end
end

end
