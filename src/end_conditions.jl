module EndConditions
using ..BaseDefinitions

export rail_end, thrusted_end, noairbrake_ballistic_end, ballistic_end, airbrake_end, drogue_end, main_end

"""
    rail_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase da rampa terminou. 

Se

`` √(Δx² + Δy²) ≥ L_trilho ``,

o foguete está suficientemente longe da origem. Com o fim dessa fase, começa o voo
propulsionado pelo motor.
"""
function rail_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return √(X.x^2+(X.y)^2) >= env.rail.length
end

"""
    thrusted_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase de queima do motor terminou.

Se ``t_simulação ≥ tempo_queima, encerra a queima do motor. Depois dessa fase, o foguete
executa o voo livre.

> **Obs**: se a tabela de empuxo tiver dados além do tempo_queima, eles são ignorados.
"""
function thrusted_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return t >= rocket.propulsion.burn_time
end

"""
    noairbrake_ballistic_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase de voo livre no voo sem airbrake terminou.

O voo livre termina no apogeu, isto é, o primeiro instante no qual ``vᵧ ≤ 0``.
O drogue é acionado no fim do voo livre.
"""
function noairbrake_ballistic_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return X.vy ≤ 0
end

#a condição de término da fase balística depende do foguete. Portanto é passada como input

"""
    airbrake_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase de voo sob efeito do airbrake terminou.

A fase do airbrake termina no apogeu, isto é, o primeiro instante no qual ``vᵧ ≤ 0``.
O drogue é acionado depois dessa fase.
"""
function airbrake_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return  X.vy ≤ 0
end
"""
    drogue_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se a fase de voo com o drogue aberto terminou.

Ao atingir uma certa altura do solo, o drogue deve ser cortado para que o *main*
possa ser aberto. Isso ocorre a ``h ≤ 300 m ``. Essa altura é input da REC. 

> Nota para o futuro: verificar se existe a possibilidade dessa altura mudar.
"""
function drogue_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    #parametrizar o 300? input de REC
    return X.y <= 300
end

"""
    main_end(X::StateVector, rocket::Rocket, env::Environment, t::Float64)

Verifica se voo terminou.

O foguete cai sob efeito do paraquedas *main* até que atinja o solo (y ≤ 0).
"""
function main_end(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    return X.y <= 0
end
end