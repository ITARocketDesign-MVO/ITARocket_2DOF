#Coca, só atualizei umas coisas envolvendo o dicionário de condições de voo, checa lá na base_def
#acho que tá bem mais claro o que é cada coisa agora ♡


#gambi furiosa pra converter uma dinâmica (retorna força) pra derivada do vetor de estado
function Xdot(t::Float64, X::StateVector, rocket::Rocket, env::Environment, phase::Int)
    forces = rocket.flight_phases[phase].dynamic(t, X, rocket, env)
    acc = forces ./ (rocket.empty_mass + rocket.propulsion.prop_mass * (1 - t / rocket.propulsion.burn_time))
    return StateVector(
        X.vx,
        X.vy,
        acc[1],
        acc[2]
    )
end

function rk4solver(t::Real, X::StateVector, rocket::Rocket,
                   phase::Int, env::Environment, dt::Float64)

    k1 = Xdot(     t    ,         X       , rocket, env, phase)
    k2 = Xdot(t + dt / 2, X + (dt / 2) *k1, rocket, env, phase)
    k3 = Xdot(t + dt / 2, X + (dt / 2) *k2, rocket, env, phase)
    k4 = Xdot(  t + dt  ,      X + k3     , rocket, env, phase)

    return X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function solveStage(t::Real, X0::StateVector, phase::Int,
                    rocket::Rocket, env::Environment, dt::Float64)

    # Praticamente toda a memoria que a funcao aloca ta aqui
    all_Xs = Vector{Any}(undef, Int64(1000 / dt))
    all_Xs[1] = X0
    j = 2

    while !rocket.flight_phases[phase].end_condition(t, all_Xs[j - 1],
                                                           rocket, env)
        #usar um push!? para voos longos é importante
        all_Xs[j] = rk4solver(t, all_Xs[j - 1], rocket, phase, env, dt)

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
    phase = 1
    fullFlight = Dict{Any, Any}()
    transition_state = X0
    t = 0.0

    while true
        all_Xs, t = solveStage(t, transition_state, phase,
                                                rocket, env, dt)
        fullFlight[rocket.flight_phases[phase].name] = all_Xs #armazena o t aqui também plz!
        transition_state = all_Xs[end]

        if phase == length(rocket.flight_phases)
            fullFlight[rocket.flight_phases[phase].name] = Vector{Any}(undef, 1)
            fullFlight[rocket.flight_phases[phase].name][1] = all_Xs[end]
            return fullFlight
        end
        phase += 1
    end
end
