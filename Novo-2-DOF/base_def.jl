<<<<<<< HEAD
=======
module BaseDefinitions


#exportar menos coisas? (só StateVector, Rkt e Amb)
export StateVector, Aed, Parachute, Propulsion, Rocket, Rail, Environment

"Representação do vetor de estados do foguete."
>>>>>>> base_defs_julia
struct StateVector
    #distância horizontal a partir do local de lançamento
    x::Float64
    #altitude do foguete, orientada p cima, a partir do nível do mar
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

"Representação de dados aerodinâmicos de algum objeto.
Contém o coeficiente de arrasto e a área transversal do objeto em questão"
struct Aed
    #colocar array - 2a coluna pra valores correspondentes
    #de velocidade
    #coeficiente de arrasto - constante ou matriz n x 2 contendo
    #pontos de (Cd, velocidade)
    Cd::Union{Real, Vector{Real}}
    #area da seção transversal do objeto
    area::Float64
end

"""
Representação de um paraquedas.
Consiste em uma condição de ativação e uma struct de aerodinâmica Aed.
"""
struct Parachute
    aed::Aed
    #função que retorna valor booleano (ativar paraquedas? sim/não)
    activate_condition::Function
end

"Representação do motor do foguete."
struct Propulsion
    #constante ou matriz n x 2, com (empuxo, tempo)
    thrust::Union{Real, Array{Real}}
    #massa total de propelente
    prop_mass::Real
    #tempo de queima do motor (caso empuxo constante)
    #ou trunca a tabela de empuxo (implementar)
    burn_time::Real
end

"Estrutura do foguete. Contém todas as informações pertinentes ao voo, exceto as características do ambiente."
struct Rocket
    #massa vazia, incluindo motor, sem propelente
    empty_mass::Real
    propulsion::Propulsion
    aed::Aed
    drogue::Parachute
    main::Parachute
    #chave para os dicionários de condição
    condition::String
    #dicionário de funções de dinâmica
    dynamics::Dict{String, Function}
    #dicionário de testes de mudança de condição de voo
    dynamic_end_conditions::Dict{String, Function}
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
    g::Union{Float64, Function}
    #densidade do ar
    ρ::Union{Float64, Function}
    rail::Rail
    #altitude de lançamento, acima do nível do mar
    launch_altittude::Real
end
