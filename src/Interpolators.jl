module Interpolators

using ....BaseDefinitions
export currentCd, currentThrust

"""
    interpolate_table(table::Matrix{Float64}, x_query::Float64)

Interpolação linear genérica de tabela, para uso em outros interpoladores.

Assume-se que a tabela contém duas colunas, a primeira contendp pontos da variável
independente e a segunda, da variável dependente. A primeira coluna deve estar em 
ordem estritamente crescente.
"""
function interpolate_table(table::Matrix{Float64}, x_query::Float64)
    if !(table[1,1] <= x_query <= table[end, 1])
        #joga erro que pode ser capturado para especficar comportamento
        throw(BoundsError("Query $x_query out of bounds [$(table[1,1]), $(table[end, 1])"))
    end
    #verifica se a query pertence à tabela
    query_index = findfirst(x -> x == x_query, table[:, 1])
    if !isnothing(query_index)
        return table[query_index, 2]
    end

    #busca o intervalo da query
    index_before_query = findlast(x -> x < x_query, table[:, 1])
    return table[index_before_query, 2] + (table[index_before_query+1, 2] - table[index_before_query]) *
                                (x_query - table[index_before_query, 1]) / (table[index_before_query+1, 1])
end


function currentCd(X::StateVector, rocket::Rocket, env::Environment, phase::Int)
    return internalcurrentCd(X, rocket.flight_phases[phase].aed.Cd, env) #se a tabela de CD ficar guardada na fase 1
end

function internalcurrentCd(X::StateVector, Cd::Real, env::Environment)
    return Cd
end

function internalcurrentCd(X::StateVector, Cd::Matrix{Float64}, env::Environment)
    v=sqrt(X.vx^2+X.vy^2)                 #velocidade do foguete
     
    N_mach = v / env.v_sound(X.y + env.launch_altittude)
    
    return interpolate_table(Cd, N_mach)
end

function currentThrust(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return internalcurrentThrust(t, rocket.propulsion.thrust) - env.Patm(X.y + env.launch_altittude) * rocket.nozzle_area
end

function internalcurrentThrust(t::Float64, thrust::Real)
    return thrust
end

function internalcurrentThrust(t::Float64, thrust::Matrix{<:Real})
    try
        return interpolate_table(thrust, t)
    catch e
        (typeof(e) == BoundsError) && return 0
    end
end



end