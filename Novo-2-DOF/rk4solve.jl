function rk4solver(t::Float64, X::StateVector, dXdt::Function, dt::Float64)

    k1 = dXdt(     t    ,        X         )
    k2 = dXdt(t + dt / 2, X + (dt / 2) * k1)
    k3 = dXdt(t + dt / 2, X + (dt / 2) * k2)
    k4 = dXdt(  t + dt  ,      X + k3      )

    X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function rk4solution((t0, tmax)::Tuple{Number, Number}, X0::StateVector,
                        dXdt::Function, dt::Float64=0.001)
                              #Padronizando 0.001 de step size

    t_range = t0:dt:tmax
    all_Xs = Vector{StateVector}(undef, length(t_range) + 1)
    all_Xs[1] = X0
    j = 2

    for t in t_range
        all_Xs[j] = rk4solver(t, all_Xs[j - 1], dXdt, dt)
        j += 1
    end

    return all_Xs
end
