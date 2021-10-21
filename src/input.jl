module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input, read_project 

include("end_conditions.jl")
using .EndConditions

include("dynamics.jl")
using .Dynamics

include("ambient_conditions.jl")

function manual_input(;
    empty_mass::Real,
    rocket_cd::Real,
    rocket_area::Real,
    thrust::Real,
    propellant_mass::Real,
    burn_time::Real,
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
    rail_phase = FlightPhase("rail", acc_rail, rail_end)
    thrusted_phase = FlightPhase("thrusted", acc_thrusted, thrusted_end)
    ballistic_phase = FlightPhase("ballistic", acc_ballistic, ballistic_end)
    drogue_phase = FlightPhase("drogue", acc_drogue, drogue_end)
    main_phase = FlightPhase("main", acc_main, main_end)

    phases = [rail_phase, thrusted_phase, ballistic_phase, drogue_phase, main_phase]
    rocket = Rocket(empty_mass, motor, Aed(rocket_cd, rocket_area),
                     drogue, main, phases)

    return X₀, rocket, env
end

function read_cd(projeto::String)
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

function read_thrust(projeto::String)
    tempo = []    #vetor nulo
    Empuxo = []    #vetor nulo
    caminho = string("./", projeto, "/Empuxo.dat")
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

function read_project(projeto::String)
    #valores-padrão impossíveis para cada input 
    input_vals = Dict{String, Float64}(
        "Massa vazia"                 => -1,
        "Cd do foguete"               => -1,
        "Area transversal do foguete" => -1,
        "Diametro do foguete"         => -1,
        "Raio do foguete"             => -1,
        "Empuxo"                      => -1,
        "Massa de propelente"         => -1,
        "Tempo de queima"             => -1,
        "Cd do drogue"                => -1,
        "Area do drogue"              => -1,
        "Cd do main"                  => -1,
        "Area do main"                => -1,
        "Angulo de lancamento"        => -1,
        "Altitude de lancamento"      => -1,
        "Comprimento do trilho"       => -1
    )

    input_file = "./" * projeto * "/Entradas.txt"
    open(input_file, "r") do input
        for line in eachline(input)
            line = lstrip(rstrip(line))
            if isempty(line) continue end
            tokens = split(line, ":")
            if length(tokens) != 2
                error("Cada linha de input deve ter um :.")
            end
            if tokens[1] in keys(input_vals)
                input_vals[tokens[1]] = parse(Float64, tokens[2])
            else
                error("$(tokens[1]) não é uma entrada válida.")
            end
        end
    end
    #verifica se todos os inputs foram lidos
    # alternative_input_keys = ["Area transversal do foguete", "Diametro do foguete", "Raio do foguete"]
    # common_input_keys = [key for key in keys(input_vals) if !(key in alternative_input_keys)]
    # if all(input_vals.[alternative_input_keys] .< 0) || any(input_vals.[common_input_keys] .< 0)
    #     problem_keys = [key for key in keys(input_vals) if input_vals[key] < 0]
    #     error("A entrada $(problem_keys[1]) não foi recebida")
    # end

    #calculo do diametro do foguete com base em qual possibilidade foi lida
    if input_vals["Diametro do foguete"] > 0
        rocket_area = π/4 * input_vals["Diametro do foguete"]^2
    elseif input_vals["Raio do foguete"] > 0
        rocket_area = π * input_vals["Raio do foguete"]^2
    elseif input_vals["Area transversal do foguete"] > 0
        rocket_area = input_vals["Area transversal do foguete"]
    end

    return manual_input(
            empty_mass      = input_vals["Massa vazia"],
            rocket_cd       = input_vals["Cd do foguete"],
            rocket_area     = rocket_area,
            thrust          = input_vals["Empuxo"],
            propellant_mass = input_vals["Massa de propelente"],
            burn_time       = input_vals["Tempo de queima"],
            drogue_cd       = input_vals["Cd do drogue"],
            drogue_area     = input_vals["Area do drogue"],
            main_cd         = input_vals["Cd do main"],
            main_area       = input_vals["Area do main"],
            launch_angle    = input_vals["Angulo de lancamento"],
            launch_altitude = input_vals["Altitude de lancamento"],
            rail_length     = input_vals["Comprimento do trilho"]
        )
end
end
