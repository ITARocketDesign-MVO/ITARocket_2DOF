module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input, Leitcd, Leithrust

include("end_conditions.jl")
using .EndConditions

include("dynamics.jl")
using .Dynamics

include("ambient_conditions.jl")

function manual_input(;
    empty_mass::Real,
    rocket_cd::Real,
    rocket_area::Real,
    thrust::Union{Real, Matrix{<:Real}},
    propellant_mass::Real,
    burn_time::Real,
    airbreak_cd::Real,
    airbreak_area::Real,
    drogue_cd::Real,
    drogue_area::Real,
    main_cd::Real,
    main_area::Real,
    launch_angle::Real,
    launch_altitude::Real,
    rail_length::Real
)
    X₀ = StateVector(0, 0, 0, 0)

    rail = Rail(rail_length, launch_angle, 0.03)

    #mudar para funções
    env = Environment(AmbientConditions.g, AmbientConditions.rho, AmbientConditions.Vsom, rail, launch_altitude)

    #parametrizar condições de abertura
    drogue = Aed(drogue_cd, drogue_area)
    main = Aed(main_cd, main_area)

    motor = Propulsion(thrust, propellant_mass, burn_time)

    #fases de voo
    #incluir módulo das dinâmicas aqui
    rail_phase = FlightPhase("rail", acc_rail, rail_end                    , Aed(  rocket_cd,   rocket_area))
    thrusted_phase = FlightPhase("thrusted", acc_thrusted, thrusted_end    , Aed(  rocket_cd,   rocket_area))
    ballistic_phase = FlightPhase("ballistic", acc_ballistic, ballistic_end, Aed(  rocket_cd,   rocket_area))
    airbreak_phase = FlightPhase("airbreak", acc_airbreak, airbreak_end    , Aed(airbreak_cd, airbreak_area))
    drogue_phase = FlightPhase("drogue", acc_drogue, drogue_end            , Aed(  drogue_cd,   drogue_area))
    main_phase = FlightPhase("main", acc_main, main_end                    , Aed(    main_cd,     main_area))

    phases = [rail_phase, thrusted_phase, ballistic_phase, airbreak_phase, drogue_phase, main_phase]
    rocket = Rocket(empty_mass, motor, phases)

    return X₀, rocket, env
end

function Leitcd(projeto::String)
    vel = [];   #vetor nulo
    cd = [];    #vetor nulo
    caminho = string("./", projeto, "/CDvMach.dat")
    x = open(caminho,"r") do x2
        for i in eachline(x2) 
            numeros = rsplit(i, "   ")                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
            push!(vel, parse(Float64, numeros[2]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(cd, parse(Float64, numeros[3]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
       end                                             #no caso transforma string para float
    end
    Cd = hcat(vel, cd);  #concatena duas matrizes no  sentido das colunas 
    return Cd;
end

function Leithrust(projeto::String)
    tempo = []    #vetor nulo
    Empuxo = []    #vetor nulo
    caminho = string("./", projeto, "/Empuxo_completo.dat")
    x = open(caminho,"r") do x
        for i in eachline(x) 
            numeros = rsplit(i, "\t")                   #Separa a string em um vetor de string (obs.: separa a string de acordo com "\t")
            push!(tempo, parse(Float64, numeros[1]));   #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(Empuxo, parse(Float64, numeros[2]));  #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
        end                                             #no caso transforma string para float
    end
    thrust = hcat(tempo, Empuxo)  #concatena duas matrizes no  sentido das colunas 
    return thrust;
end


end
