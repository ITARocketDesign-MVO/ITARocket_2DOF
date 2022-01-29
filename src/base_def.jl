module BaseDefinitions

export StateVector, Aed, Propulsion, FlightPhase, Rocket, Rail, Environment, SimResults

"Representação do vetor de estados do foguete."
struct StateVector
    #distância horizontal a partir do local de lançamento
    x::Float64
    #altitude do foguete, orientada p cima, a partir da plataforma de lançamento
    y::Float64
    #velocidade em x
    vx::Float64
    #velocidade em y
    vy::Float64
end

"""
    Base.:+(vec1::StateVector, vec2::StateVector)

Soma dois vetores de estado.

Serve principalmente para calcular o próximo vetor de estados:

> X_{n+1} = X_{n} + dX
"""
function Base.:+(vec1::StateVector, vec2::StateVector)
    StateVector(vec1.x + vec2.x,
                vec1.y + vec2.y,
                vec1.vx + vec2.vx,
                vec1.vy + vec2.vy
                )
end

"""
    Base.:*(α::Real, vec::StateVector)

Multiplica um vetor de estados por um escalar à esquerda.

Serve principalmente para multiplicar a derivada pelo passo de tempo:
> dX = dt * (dX/dt)
"""
function Base.:*(α::Real, vec::StateVector)
    StateVector(α*vec.x,
                α*vec.y,
                α*vec.vx,
                α*vec.vy
                )
end

function Base.:-(vec1::StateVector, vec2::StateVector)
    StateVector(vec1.x - vec2.x,
                vec1.y - vec2.y,
                vec1.vx - vec2.vx,
                vec1.vy - vec2.vy
                )
end

"Representação de dados aerodinâmicos de algum objeto.
Contém o coeficiente de arrasto e a área transversal do objeto em questão"
struct Aed
    #colocar array - 2a coluna pra valores correspondentes
    #de velocidade
    #coeficiente de arrasto - constante ou matriz n x 2 contendo
    #pontos de (Cd, N_mach)
    Cd::Union{Real, Matrix{<:Real}}
    #area da seção transversal do objeto
    area::Float64
end

"Representação do motor do foguete."
struct Propulsion
    #constante ou matriz n x 2, com (empuxo, tempo)
    thrust::Union{Real, Matrix{<:Real}}
    #massa total de propelente
    prop_mass::Real
    #tempo de queima do motor (caso empuxo constante)
    #ou trunca a tabela de empuxo (implementar)
    burn_time::Real
end

"Representação de uma fase de voo do foguete. Contém a dinâmica da fase e a condição para avançar para a próxima fase."
struct FlightPhase
    name::String
    dynamic::Function
    end_condition::Function
    aed::Aed
end

"Estrutura do foguete. Contém todas as informações pertinentes ao voo, exceto as características do ambiente."
struct Rocket
    #massa vazia, incluindo motor, sem propelente
    empty_mass::Real
    propulsion::Propulsion
    flight_phases::Vector{FlightPhase}
end

"Representação da rampa de lançamento."
struct Rail
    length::Real
    #graus - usar funções sind e cosd
    θ_ground::Real
    #coeficiente de atrito
    μ::Real
end

"Representação do ambiente de voo do foguete."
struct Environment
    #módulo da gravidade
    g::Function
    #densidade do ar
    ρ::Function
    #velocidade do som (para calcular o número de Mach)
    v_sound::Function
    rail::Rail
    #altitude de lançamento, acima do nível do mar
    launch_altittude::Real
end

"Representação dos dados obtidos da simulação."
struct SimResults
    dt::Float64
    state_vector_list::Vector{StateVector}
    phase_transition_times::Vector{Float64}
    phases::Vector{String}
end

import Base: getindex

"""
    getindex(res::SimResults, t::Float64)

Indexação dos resultados de simulção pelo tempo.

Qualquer valor de tempo entre o começo e o fim do voo é aceito. 
O valor de retorno é linearmente interpolado entre estados adjacentes.
"""
function getindex(res::SimResults, t::Float64)
    if !(0 <= t <= res.dt*length(res.state_vector_list))
        throw(BoundsError(res.state_vector_list, t))
    end
    
    #interpola estados mais próximos
    fl = Int(floor(t/res.dt))
    return res.state_vector_list[fl] + (t/res.dt - fl) * res.state_vector_list[fl+1]
end

"""
    getindex(res::SimResults, phase::String)

Seleção dos estados que pertencem a uma fase do voo do foguete.

A indexação é feita com os nomes das fases:
* "rail"
* "thrusted"
* "ballistic"
* "airbrake"
* "drogue"
* "main"

*Obs*: o último estado de uma fase é sempre igual ao primeiro da próxima. É uma feature, não um bug.
"""
function getindex(res::SimResults, phase::String)
    if !(phase in res.phases)
        throw(KeyError(phase))
    end

    #retorna um vetor com os estados dessa fase
    phase_index = findfirst(el -> el==phase, res.phases)
    phase_start = (phase_index == 1) ? 0 : res.phase_transition_times[phase_index-1]
    phase_end = res.phase_transition_times[phase_index]
    #algo de errado aqui
    index_start = Int(floor(phase_start/res.dt))+1
    index_end = Int(floor(phase_end/res.dt))+1
    return res.state_vector_list[index_start:index_end]
end

end