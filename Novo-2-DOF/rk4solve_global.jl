function rk4solver(t::Real, X::StateVector, dt::Float64)
    global rocket, env

    k1 = rocket.dynamics[rocket.condition](     t    ,        X        )
    k2 = rocket.dynamics[rocket.condition](t + dt / 2, X + (dt / 2) *k1)
    k3 = rocket.dynamics[rocket.condition](t + dt / 2, X + (dt / 2) *k2)
    k4 = rocket.dynamics[rocket.condition](  t + dt  ,      X + k3     )

    return X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function solveStage(t::Real, X0::StateVector, dt::Float64=0.01)
    global rocket, env

    # Praticamente toda a memoria que a funcao aloca ta aqui
    # Definir uma estimativa razoavel para o tempo maximo
    # em cada dinamica
    all_Xs = Vector{Any}(undef, Int64(500 / dt))
    all_Xs[1] = X0
    j = 2

    while !rocket.dynamic_end_conditions[rocket.condition](t, all_Xs[j - 1])
        all_Xs[j] = rk4solver(t, all_Xs[j - 1], dt)
        j += 1
        t += dt
    end

    # N tem nenhum jeito de passar pra proxima condicao
    new_condition = rocket.condition_sequence[rocket.condition]

    return all_Xs[1:j - 1], new_condition
end
