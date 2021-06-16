function rk4solver(t::Real, X::StateVector, rocket::Rocket,
                   condition::String, env::Environment, dt::Float64)

    k1 = rocket.dynamics[condition](     t    ,         X       , rocket, env)
    k2 = rocket.dynamics[condition](t + dt / 2, X + (dt / 2) *k1, rocket, env)
    k3 = rocket.dynamics[condition](t + dt / 2, X + (dt / 2) *k2, rocket, env)
    k4 = rocket.dynamics[condition](  t + dt  ,      X + k3     , rocket, env)

    return X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function solveStage(t::Real, X0::StateVector, condition::String,
                    condition_sequence::Dict{String, String},
                    rocket::Rocket, env::Environment, dt::Float64)

    # Praticamente toda a memoria que a funcao aloca ta aqui
    all_Xs = Vector{Any}(undef, Int64(1000 / dt))
    all_Xs[1] = X0
    j = 2

    while !rocket.dynamic_end_conditions[condition](t, all_Xs[j - 1],
                                                           rocket, env)

        all_Xs[j] = rk4solver(t, all_Xs[j - 1], rocket, condition, env, dt)

        # Pra n ficar infinito, significa que alguma condicao eh incoerente
        if all_Xs[j].y == Inf
            return
        end

        j += 1
        t += dt
    end

    # Retorna a proxima condicao
    new_condition = condition_sequence[condition]

    return all_Xs[1:j - 1], new_condition, t - dt
end

function fullFlight(rocket::Rocket, env::Environment,
                     condition_sequence::Dict{String, String},
                     X0::StateVector=StateVector(0, 0, 0, 0),
                     dt::Float64=0.001)

    condition = "inicio"
    fullFlight = Dict{Any, Any}()
    transition_state = X0
    t = 0.0

    while true
        all_Xs, new_condition, t = solveStage(t, transition_state, condition,
                                          condition_sequence, rocket, env, dt)
        fullFlight[condition] = all_Xs
        transition_state = all_Xs[end]
        condition = new_condition

        if condition == "fim"
            fullFlight[condition] = Vector{Any}(undef, 1)
            fullFlight[condition][1] = all_Xs[end]
            return fullFlight
        end
    end
end
