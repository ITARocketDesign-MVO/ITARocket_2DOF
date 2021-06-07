function rk4solver(t::Float64, X::StateVector,
                dXdt::Function, dt::Float64)
                            # Padronizando o 0.001 de step size

    k1 = dXdt(     t    ,        X         )
    k2 = dXdt(t + dt / 2, X + (dt / 2) * k1)
    k3 = dXdt(t + dt / 2, X + (dt / 2) * k2)
    k4 = dXdt(  t + dt  ,      X + k3      )

    X + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)

end

function rk4solution((t0, tmax)::Tuple{Number, Number}, X0::StateVector,
                        dXdt::Function, dt::Float64=0.001)

    t_range = t0:dt:tmax
    all_Xs = Dict{Float64, StateVector}(t0 => X0)
    # Ja testei, Dict eh mais rapido que Array

    for i in 2:length(t_range)
        t1 = t_range[i-1]
        t2 = t_range[i]
        all_Xs[t2] = rk4solver(t1, all_Xs[t1], dXdt, dt)
    end
    
    return all_Xs
end
