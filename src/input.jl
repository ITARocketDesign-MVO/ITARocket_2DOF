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
    rocket_cd::Union{Real, Matrix{Float64}},
    rocket_area::Real,
    thrust::Union{Real, Matrix{Float64}},
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

function read_cd(filename::String = "CDvMach.dat"; project::String = "")
    vel = [];   #vetor nulo
    cd = [];    #vetor nulo
    folder = "./" * project * ((isempty(project)) ? "" : "/") 
    path = string(folder, filename)
    x = open(path,"r") do x2
        for i in eachline(x2) 
            numeros = rsplit(i, "   ")                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
            push!(vel, parse(Float64, numeros[2]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(cd, parse(Float64, numeros[3]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
       end                                             #no caso transforma string para float
    end
    Cd = hcat(vel, cd);  #concatena duas matrizes no  sentido das colunas 
    return Cd;
end

function read_thrust(filename::String = "Empuxo.dat"; project::String = "")
    tempo = []    #vetor nulo
    Empuxo = []    #vetor nulo
    folder = "./" * project * ((isempty(project)) ? "" : "/") 
    path = string(folder, filename)
    x = open(path,"r") do x
        for i in eachline(x) 
            numeros = rsplit(i, "\t")                   #Separa a string em um vetor de string (obs.: separa a string de acordo com "\t")
            push!(tempo, parse(Float64, numeros[1]));   #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(Empuxo, parse(Float64, numeros[2]));  #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
        end                                             #no caso transforma string para float
    end
    thrust = hcat(tempo, Empuxo)  #concatena duas matrizes no  sentido das colunas 
    return thrust;
end

module InParameters

    struct InputConverter
        name::String
        converter::Function
    end
    function (conv::InputConverter)(x)
        conv.converter(x)
    end
    function (conv::InputConverter)(x, y)
        try
            conv.converter(x, y)
        catch e
            if e isa MethodError
                conv(x)
            end
        end
    end

    mutable struct InputParameter{T}
        value::Union{Nothing, T}    #usar inicialização incompleta?
        converters::Vector{InputConverter}
        type::Type
        function InputParameter{T}(converters::Vector{InputConverter}) where {T}
            new(nothing, converters, T)
        end
    end

    function (param::InputParameter)(name::String, value::String, proj::String)
        if name in [converter.name for converter in param.converters]
            for converter in param.converters
                if converter.name == name
                    param.value = converter(value, proj)
                    return true
                end
            end
        end
        return false
    end

    empty_mass_c      = InputConverter("Massa vazia", x -> parse(Float64, x))
    rocket_cd_c       = InputConverter("Cd do foguete", x -> parse(Float64, x))
    rocket_cd_table_c = InputConverter("Tabela de Cd do foguete", (fname, proj) -> begin
                            if fname == "tabela"
                                parentmodule(InParameters).read_cd(project=proj)
                            else
                                parentmodule(InParameters).read_cd(fname, project=proj)
                            end
                        end)
    rocket_area_c   = InputConverter("Area transversal do foguete", x -> parse(Float64, x))
    rocket_diam_c   = InputConverter("Diametro do foguete", x -> π/4*parse(Float64, x)^2)
    rocket_radius_c = InputConverter("Raio do foguete"    , x -> π*parse(Float64, x)^2)
    thrust_c        = InputConverter("Empuxo", x -> parse(Float64, x))
    thrust_table_c  = InputConverter("Tabela de Empuxo", (fname, proj) -> begin
                            if fname == "tabela"
                                parentmodule(InParameters).read_thrust(project=proj)
                            else
                                parentmodule(InParameters).read_thrust(fname, project=proj)
                            end
                        end)
    propellant_mass_c = InputConverter("Massa de propelente",    x -> parse(Float64, x))
    burn_time_c       = InputConverter("Tempo de queima",        x -> parse(Float64, x))
    drogue_cd_c       = InputConverter("Cd do drogue",           x -> parse(Float64, x))
    drogue_area_c     = InputConverter("Area do drogue",         x -> parse(Float64, x))
    main_cd_c         = InputConverter("Cd do main",             x -> parse(Float64, x))
    main_area_c       = InputConverter("Area do main",           x -> parse(Float64, x))
    launch_angle_c    = InputConverter("Angulo de lancamento",   x -> parse(Float64, x))
    launch_altitude_c = InputConverter("Altitude de lancamento", x -> parse(Float64, x))
    rail_length_c     = InputConverter("Comprimento do trilho",  x -> parse(Float64, x))

    #parametros de entrada
    empty_mass      = InputParameter{Float64                        }([empty_mass_c])
    rocket_cd       = InputParameter{Union{Float64, Matrix{Float64}}}([rocket_cd_c, rocket_cd_table_c])
    rocket_area     = InputParameter{Float64                        }([rocket_area_c, rocket_diam_c, rocket_radius_c])
    thrust          = InputParameter{Union{Float64, Matrix{Float64}}}([thrust_c, thrust_table_c])
    propellant_mass = InputParameter{Float64                        }([propellant_mass_c])
    burn_time       = InputParameter{Float64                        }([burn_time_c      ])
    drogue_cd       = InputParameter{Float64                        }([drogue_cd_c      ])
    drogue_area     = InputParameter{Float64                        }([drogue_area_c    ])
    main_cd         = InputParameter{Float64                        }([main_cd_c        ])
    main_area       = InputParameter{Float64                        }([main_area_c      ])
    launch_angle    = InputParameter{Float64                        }([launch_angle_c   ])
    launch_altitude = InputParameter{Float64                        }([launch_altitude_c])
    rail_length     = InputParameter{Float64                        }([rail_length_c    ])
    
    parameter_list = [empty_mass     ,
                      rocket_cd      ,
                      rocket_area    ,
                      thrust         ,
                      propellant_mass,
                      burn_time      ,
                      drogue_cd      ,
                      drogue_area    ,
                      main_cd        ,
                      main_area      ,
                      launch_angle   ,
                      launch_altitude,
                      rail_length    ]
    export parameter_list, param
end

using .InParameters
#validar todos os inputs
function read_project(projeto::String)
    remaining_parameters = collect(1:length(parameter_list))

    input_file = "./" * projeto * "/Entradas.txt"
    open(input_file, "r") do input
        for line in eachline(input)
            tokens = split(line, ":")
            #elimina espaço em branco nas extremidades dos tokens
            tokens = rstrip.(lstrip.(tokens))
            name = string(tokens[1])
            value = string(tokens[2])
            match = -1
            for i in remaining_parameters
                if parameter_list[i](name, value, projeto)
                    match = i
                    break
                end
            end
            popat!(remaining_parameters, findall(x -> x == match, remaining_parameters)[1])
        end
    end

    #leitura de tabelas
    if InParameters.rocket_cd.value isa String
        if InParameters.rocket_cd.value == "tabela"
            InParameters.rocket_cd.value = read_cd(project = projeto)
        else
            InParameters.rocket_cd.value = read_cd(InParameters.rocket_cd.value, project = projeto)
        end
    end
    if InParameters.thrust.value isa String
        if InParameters.thrust.value == "tabela"
            InParameters.thrust.value = read_thrust(project = projeto)
        else
            InParameters.thrust.value = read_thrust(InParameters.thrust.value, project = projeto)
        end
    end

    return manual_input(
            empty_mass      = InParameters.empty_mass.value     ,
            rocket_cd       = InParameters.rocket_cd.value      ,
            rocket_area     = InParameters.rocket_area.value    ,
            thrust          = InParameters.thrust.value         ,
            propellant_mass = InParameters.propellant_mass.value,
            burn_time       = InParameters.burn_time.value      ,
            drogue_cd       = InParameters.drogue_cd.value      ,
            drogue_area     = InParameters.drogue_area.value    ,
            main_cd         = InParameters.main_cd.value        ,
            main_area       = InParameters.main_area.value      ,
            launch_angle    = InParameters.launch_angle.value   ,
            launch_altitude = InParameters.launch_altitude.value,
            rail_length     = InParameters.rail_length.value    
        )
end


end
