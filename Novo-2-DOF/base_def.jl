module BaseDefinitions

#@TODO
#acertar formato do CD e do empuxo
#definir armazenamento da condição do foguete

#exportar menos coisas? (só StateVector, Rkt e Amb)
export StateVector, Aed, Parachute, Propulsion, Rocket, Rail, Environment


struct StateVector
    x::Float64
    y::Float64
    vx::Float64
    vy::Float64
    m_comb::Float64
end

function Base.:+(vec1::StateVector, vec2::StateVector)
    StateVector(vec1.x + vec2.x, 
                vec1.y + vec2.y,
                vec1.vx + vec2.vx,
                vec1.vy + vec2.vy,
                vec1.m_comb + vec2.m_comb)
end

function Base.:*(α::Real, vec::StateVector)
    StateVector(α*vec.x,
                α*vec.y,
                α*vec.vx,
                α*vec.vy,
                α*vec.m_comb)
end

struct Aed
    #colocar array - 2a coluna pra valores correspondentes
    #de velocidade
    Cd::Union{Real, Vector{Real}}
    area::Float64
end

struct Parachute
    aed::Aed
    #function ou só a condição mesmo? (com Symbol?)
    activate_condition::Function
end

struct Propulsion
    #especificar formato do array?
    thrust::Union{Real, Array{Real}}
    prop_mass::Real
    burn_time::Real
end

struct Rocket
    empty_mass::Real
    propulsion::Propulsion
    aed::Aed
    drogue::Parachute
    main::Parachute
    #mudar para Symbol? Ou ainda Function?
    condition::String
end

struct Rail
    length::Real
    θ_ground::Real
    μ::Real
end

struct Environment
    g::Union{Float64, Function}
    ρ::Union{Float64, Function}
    rail::Rail
    launch_altittude::Real
end

end