#Coca, só atualizei umas coisas envolvendo o dicionário de condições de voo, checa lá na base_def
#acho que tá bem mais claro o que é cada coisa agora ♡

function rk4solver(t::Real, X::StateVector, rocket::Rocket,
                   condition::String, env::Environment, dt::Float64)

    k1 = rocket.dynamics[condition](     t    ,         X       , rocket, env)
    k2 = rocket.dynamics[condition](t + dt / 2, X + (dt / 2) *k1, rocket, env)
    k3 = rocket.dynamics[condition](t + dt / 2, X + (dt / 2) *k2, rocket, env)
    k4 = rocket.dynamics[condition](  t + dt  ,      X + k3     , rocket, env)

    return X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function solveStage(t::Real, X0::StateVector, condition::Int,
                    rocket::Rocket, env::Environment, dt::Float64)

    # Praticamente toda a memoria que a funcao aloca ta aqui
    all_Xs = Vector{Any}(undef, Int64(1000 / dt))
    all_Xs[1] = X0
    j = 2

    while !rocket.flight_phases[condition].end_condition(t, all_Xs[j - 1],
                                                           rocket, env)

        all_Xs[j] = rk4solver(t, all_Xs[j - 1], rocket, condition, env, dt)

        # Pra n ficar infinito, significa que alguma condicao eh incoerente
        if all_Xs[j].y == Inf
            return
        end

        j += 1
        t += dt
    end

    #t+dt!!!!! 
    #return all_Xs[1:j - 1], t - dt
    return all_Xs[1:j - 1], t + dt
end

function fullFlight(rocket::Rocket, env::Environment,
                     X0::StateVector,
                     dt::Float64=0.001)
    #X0 vem definido do input já
    condition = 1
    fullFlight = Dict{Any, Any}()
    transition_state = X0
    t = 0.0

    while true
        all_Xs, t = solveStage(t, transition_state, condition,
                                                rocket, env, dt)
        fullFlight[rocket.flight_phases[condition].name] = all_Xs #armazena o t aqui também plz!
        transition_state = all_Xs[end]

        if condition == length(rocket.flight_phases)
            fullFlight[rocket.flight_phases[condition].name] = Vector{Any}(undef, 1)
            fullFlight[rocket.flight_phases[condition].name][1] = all_Xs[end]
            return fullFlight
        end
        condition += 1
    end
end
