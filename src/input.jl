"Definições e funções de entrada de parâmetros."
module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input, read_project, read_cd, read_thrust

include("end_conditions.jl")
using .EndConditions

include("dynamics.jl")
using .Dynamics

include("ambient_conditions.jl")
"""
    manual_input(; kwargs)

Input manual dos parâmetros de voo do foguete. 

Retorna: 

* `X₀::StateVector` - vetor de estado inicial
* `rocket::Rocket` - struct representando o foguete
* `env::Environment` - struct representando o ambiente

Todos os parâmetros são *keyword arguments* para clareza na chamada da função.
As fases de voo são definidas nessa função. Ela também é usada pela `read_project`.

Autor: Pulga
"""
function manual_input(;
    empty_mass::Real,
    rocket_cd::Union{Real, Matrix{<:Real}},
    rocket_area::Real,
    thrust::Union{Real, Matrix{<:Real}},
    propellant_mass::Real,
    burn_time::Real,
    airbrake_cd::Union{Real, Matrix{<:Real}},
    airbrake_area::Real,
    drogue_cd::Real,
    drogue_area::Real,
    main_cd::Real,
    main_area::Real,
    launch_angle::Real,
    launch_altitude::Real,
    rail_length::Real,
    airbrake_option::String = "noairbrake", #valores: "noairbrake", "justairbrake", "fulllogic"
    airbrake_opening_logic::Function = x -> x,
    nozzle_area::Real
)
    X₀ = StateVector(0, 0, 0, 0)

    rail = Rail(rail_length, launch_angle, 0.03)

    env = Environment(AmbientConditions.g, AmbientConditions.rho, AmbientConditions.Vsom, rail, launch_altitude, AmbientConditions.Patm)

    drogue = Aed(drogue_cd, drogue_area)
    main = Aed(main_cd, main_area)

    motor = Propulsion(thrust, propellant_mass, burn_time)

    #fases de voo
    #incluir módulo das dinâmicas aqui
    rail_phase = FlightPhase("rail", acc_rail, rail_end                    , Aed(  rocket_cd,   rocket_area))
    thrusted_phase = FlightPhase("thrusted", acc_thrusted, thrusted_end    , Aed(  rocket_cd,   rocket_area))
    drogue_phase = FlightPhase("drogue", acc_drogue, drogue_end            , Aed(  drogue_cd,   drogue_area))
    main_phase = FlightPhase("main", acc_main, main_end                    , Aed(    main_cd,     main_area))
    
    if airbrake_option == "noairbrake"
        ballistic_phase = FlightPhase("ballistic", acc_ballistic, noairbrake_ballistic_end, Aed(  rocket_cd,   rocket_area))
        phases = [rail_phase, thrusted_phase, ballistic_phase, drogue_phase, main_phase]
    elseif airbrake_option == "justairbrake"
        airbrake_phase = FlightPhase("airbrake", acc_airbrake, airbrake_end    , Aed(airbrake_cd, airbrake_area))
        phases = [rail_phase, thrusted_phase, airbrake_phase, drogue_phase, main_phase]
    elseif airbrake_option == "fulllogic"
        ballistic_phase = FlightPhase("ballistic", acc_ballistic, airbrake_opening_logic, Aed(rocket_cd, rocket_area))
        airbrake_phase = FlightPhase("airbrake", acc_airbrake, airbrake_end    , Aed(airbrake_cd, airbrake_area))
        phases = [rail_phase, thrusted_phase, ballistic_phase, airbrake_phase, drogue_phase, main_phase]
    else
        error("Possible values for airbrake_option are \"noairbrake\", \"justairbrake\", \"fulllogic\"")
    end
    rocket = Rocket(empty_mass, motor, phases, nozzle_area)

    return X₀, rocket, env
end

"""
    read_cd(filename::String = "CDvMach.dat"; project::String = "")

Leitura de uma tabela de Cd por número de Mach em arquivo.

Retorna:

* `Cd::Matrix{Float64}` - matriz com número de Mach na 1ᵃ coluna e Cd na 2ᵃ

Os argumentos são opcionais. Se nenhum for passado, a função tentará abrir o arquivo
`CDvMach.dat` na pasta atual. O parâmetro `projeto` especifica a pasta onde procurar
o arquivo `filename`.

Especificações do arquivo de entrada: 
    
* O arquivo deve conter apenas números, em duas colunas separadas por espaço.
* A primeira coluna é o número de Mach e a segunda, o Cd correspondente.

Autor: Barueri
"""
function read_cd(filename::String = "CDvMach.dat"; project::String = "")
    vel = [];   #vetor nulo
    cd = [];    #vetor nulo
    folder = "./" * project * ((isempty(project)) ? "" : "/") 
    path = string(folder, filename)
    x = open(path,"r") do x2
        for i in eachline(x2) 
            numeros = split(i, r"\s", keepempty=false)                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
            push!(vel, parse(Float64, numeros[1]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(cd, parse(Float64, numeros[2]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
       end                                             #no caso transforma string para float
    end
    Cd = hcat(vel, cd);  #concatena duas matrizes no  sentido das colunas 
    return Cd;
end

"""
    read_thrust(filename::String = "Empuxo.dat"; project::String = "")

Leitura de uma tabela de empuxo por tempo em arquivo.

Retorna:

* `thrust::Matrix{Float64}` - matriz com tempo na 1ᵃ coluna e empuxo na 2ᵃ

Os argumentos são opcionais. Se nenhum for passado, a função tentará abrir o arquivo
`Empuxo.dat` na pasta atual. O parâmetro `projeto` especifica a pasta onde procurar
o arquivo `filename`.

Especificações do arquivo de entrada: 
    
* O arquivo deve conter apenas números, em duas colunas separadas por espaço.
* A primeira coluna deve ser o instante de tempo e a segunda, o empuxo correspondente.

Autor: Barueri
"""
function read_thrust(filename::String = "Empuxo.dat"; project::String = "")
    tempo = []    #vetor nulo
    Empuxo = []    #vetor nulo
    folder = "./" * project * ((isempty(project)) ? "" : "/") 
    path = string(folder, filename)
    x = open(path,"r") do x
        for i in eachline(x) 
            numeros = split(i, r"\s", keepempty=false)                   #Separa a string em um vetor de string (obs.: separa a string de acordo com "\t")
            push!(tempo, parse(Float64, numeros[1]));   #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(Empuxo, parse(Float64, numeros[2]));  #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
        end                                             #no caso transforma string para float
    end
    thrust = hcat(tempo, Empuxo)  #concatena duas matrizes no  sentido das colunas 
    return thrust;
end


"Structs auxiliares para a leitura dos parâmetros em arquivo."
module InParameters

    "Struct para converter um input de texto do arquivo de entradas no valor de um parâmetro de voo."
    struct InputConverter
        #nome que aciona esse conversor no arquivo de entrada
        #Exemplo: valor => o conversor com nome Exemplo será chamado
        name::String
        #função de conversão
        converter::Function
    end
    function (conv::InputConverter)(x)
        conv.converter(x)
    end
    function (conv::InputConverter)(x, y)
        #para alguns conversores é necessário passar o nome do projeto também
        try
            conv.converter(x, y)
        catch e
            if e isa MethodError
                conv(x)
            end
        end
    end

    "Struct para representar um parâmetro de entrada."
    mutable struct InputParameter{T}
        #descrição do que o parâmetro representa (uso na validate_inputs)
        name::String
        #valor do parâmetro depois da conversão. Começa sempre com nothing
        #tentar inicialização incompleta (deve eliminar a Union)
        value::Union{Nothing, T}
        #lista de conversores correspondentes ao parâmetro.
        #podemos ter entrada de área, diâmetro e raio, e são todos convertidos para área
        converters::Vector{InputConverter}
        #tipo do valor (T). Deve haver um jeito mais idiomático de obter esse tipo, mas funciona 
        type::Type
        function InputParameter{T}(name::String, converters::Vector{InputConverter}) where {T}
            new(name, nothing, converters, T)
        end
    end

    #converte a entrada input com o conversor de nome name
    function (param::InputParameter)(name::String, input::String, proj::String)
        #busca o conversor de nome correto e aciona ele
        for converter in param.converters
            if converter.name == name
                param.value = converter(input, proj)
                return true
            end
        end
        return false
    end

    """
        validate_inputs(list::Vector{InputParameter})

    Verifica se todos os inputs foram recebidos e levanta um erro caso contrário.
    """
    function validate_inputs(list::Vector{InputParameter})
        for param = list
            if param.value === nothing
                error("O  parâmetro " * param.name * " não foi entrado. Use uma das possibilidades de entrada: \n" * 
                        prod([conv.name * ",\n" for conv = param.converters]))
            end
        end
    end

    """
        validate_line(line::String)

    Verifica se a linha tem o formato esperado para a leitura de dados.

    A linha deve ser vazia, um comentário (#) ou da 
    forma `Nome do parâmetro: valor`, onde o nome do parâmetro deve ser o nome de algum 
    conversor.
    """
    function validate_line(line::String)
        #1 e penas 1 : na linha.
        return count(x -> x == ':', line) == 1
    end

    #-----------------------------------------------------------------------------------
    #                   Definições específicas do foguete

    #lista de conversores
    empty_mass_c      = InputConverter("Massa vazia (kg)",            x -> parse(Float64, x))
    rocket_cd_c       = InputConverter("Cd do foguete",          x -> parse(Float64, x))
    rocket_cd_table_c = InputConverter("Tabela de Cd do foguete", (fname, proj) ->
                            (fname == "tabela") ?
                                parentmodule(InParameters).read_cd(project=proj)
                            :
                                parentmodule(InParameters).read_cd(fname, project=proj)
                            )
    rocket_area_c   = InputConverter("Area transversal do foguete (m^2)", x -> parse(Float64, x))
    rocket_diam_c   = InputConverter("Diametro do foguete (m)",      x -> π/4*parse(Float64, x)^2)
    rocket_radius_c = InputConverter("Raio do foguete (m)"    ,      x -> π*parse(Float64, x)^2)
    airbrake_cd_c   = InputConverter("Cd do airbrake", x -> parse(Float64, x))
    airbrake_area_c = InputConverter("Area do airbrake (m^2)", x -> parse(Float64, x))
    thrust_c        = InputConverter("Empuxo (N)",                   x -> parse(Float64, x))
    thrust_table_c  = InputConverter("Tabela de Empuxo",         (fname, proj) ->
                            (fname == "tabela") ?
                                parentmodule(InParameters).read_thrust(project=proj)
                            :
                                parentmodule(InParameters).read_thrust(fname, project=proj)
                            )
    propellant_mass_c  = InputConverter("Massa de propelente (kg)",    x -> parse(Float64, x))
    burn_time_c        = InputConverter("Tempo de queima (s)",        x -> parse(Float64, x))
    drogue_cd_c        = InputConverter("Cd do drogue",           x -> parse(Float64, x))
    drogue_area_c      = InputConverter("Area do drogue (m^2)",         x -> parse(Float64, x))
    main_cd_c          = InputConverter("Cd do main",             x -> parse(Float64, x))
    main_area_c        = InputConverter("Area do main (m^2)",           x -> parse(Float64, x))
    launch_angle_c     = InputConverter("Angulo de lancamento (graus)",   x -> parse(Float64, x))
    launch_altitude_c  = InputConverter("Altitude de lancamento (m)", x -> parse(Float64, x))
    rail_length_c      = InputConverter("Comprimento do trilho (m)",  x -> parse(Float64, x))
    rail_length_ft_c   = InputConverter("Comprimento do trilho (ft)",  x -> 0.3048*parse(Float64, x))
    airbrake_options_c = InputConverter("Opção de airbrake", x -> x)
    airbrake_opening_logic_c = InputConverter("Lógica de abertura do airbrake", x -> eval(Meta.parse(x)))
    nozzle_area_c = InputConverter("Area do bocal (m^2)", x -> parse(Float64, x))
    nozzle_diam_c = InputConverter("Diametro do bocal (m)", x-> π*parse(Float64, x)^2)
    nozzle_radius_c = InputConverter("Raio do bocal (m)", x-> π/4*parse(Float64, x)^2)

    #lista de parâmetros do foguete. São os mesmos que na manual_input
    empty_mass      = InputParameter{Float64}("massa vazia", [empty_mass_c])
    rocket_cd       = InputParameter{Union{Float64, Matrix{Float64}}}(
            "coeficiente de arrasto", [rocket_cd_c, rocket_cd_table_c])
    rocket_area     = InputParameter{Float64}("area transversal", [rocket_area_c, rocket_diam_c, rocket_radius_c])
    airbrake_cd     = InputParameter{Float64}("Cd do airbrake", [airbrake_cd_c])
    airbrake_area   = InputParameter{Float64}("Area do airbrake", [airbrake_area_c])
    thrust          = InputParameter{Union{Float64, Matrix{Float64}}}(
            "empuxo", [thrust_c, thrust_table_c])
    propellant_mass = InputParameter{Float64}("massa de propelente", [propellant_mass_c])
    burn_time       = InputParameter{Float64}("tempo de queima", [burn_time_c      ])
    drogue_cd       = InputParameter{Float64}("Cd do drogue", [drogue_cd_c      ])
    drogue_area     = InputParameter{Float64}("área do drogue", [drogue_area_c    ])
    main_cd         = InputParameter{Float64}("Cd do main", [main_cd_c        ])
    main_area       = InputParameter{Float64}("área do main", [main_area_c      ])
    launch_angle    = InputParameter{Float64}("ângulo de lançamento", [launch_angle_c   ])
    launch_altitude = InputParameter{Float64}("altitude de lançamento", [launch_altitude_c])
    rail_length     = InputParameter{Float64}("comprimento do trilho", [rail_length_c    ])
    airbrake_option = InputParameter{String}("Opção de airbrake", [airbrake_options_c])
    airbrake_opening_logic = InputParameter{Function}("Lógica de abertura do airbrake", [airbrake_opening_logic_c])
    nozzle_area     = InputParameter{Float64}("área do bocal", [nozzle_area_c, nozzle_diam_c, nozzle_radius_c])
    #lista de REFERENCIAS aos parâmtros para fácil iteração.
    #obs: a alteração dos elementos dessa lista altera as variáveis acima também!
    parameter_list = [empty_mass     ,
                      rocket_cd      ,
                      rocket_area    ,
                      airbrake_cd    ,
                      airbrake_area  ,
                      thrust         ,
                      propellant_mass,
                      burn_time      ,
                      drogue_cd      ,
                      drogue_area    ,
                      main_cd        ,
                      main_area      ,
                      launch_angle   ,
                      launch_altitude,
                      rail_length    ,
                      airbrake_option,
                      airbrake_opening_logic,
                      nozzle_area]
    export parameter_list, param, validate_inputs, validate_line
end

using .InParameters
"""
    read_project(projeto::String)

Leitura dos parâmetros de voo de arquivo de texto.

O arquivo de texto deve se chamar `Entradas.txt` e estar localizado numa pasta
com o nome do projeto atual. As entradas do arquivo serão lidas e convertidas
para o formato correto. Se o empuxo ou o Cd estiver na forma de arquivo de dados,
estes também serão lidos. O formato do arquivo é especificado na função 
`validate_line`.
"""
function read_project(projeto::String)
    #índices dos parâmetros que ainda não foram achados
    remaining_parameters = collect(1:length(parameter_list))

    input_file = "./" * projeto * "/Entradas.txt"
    open(input_file, "r") do input
        for line in eachline(input)
            if !validate_line(line)
                continue
            end
            tokens = split(line, ":")
            #elimina espaço em branco nas extremidades dos tokens
            tokens = rstrip.(lstrip.(tokens))
            name = string(tokens[1])
            value = string(tokens[2])
            #busca o parâmetro que se encaixa com o nome da linha atual
            match = -1
            for i in remaining_parameters
                if parameter_list[i](name, value, projeto)
                    match = i
                    break
                end
            end
            #se não achar um parâmetro correspondente, avisar e ignorar
            if match == -1
                println("A entrada $name não é reconhecida. Ela será ignorada.")
            else
                #remove o parâmetro achado da lista de parâmetros faltantes
                popat!(remaining_parameters, findall(x -> x == match, remaining_parameters)[1])
            end
        end
    end
    #verifica se todos os inputs têm valor
    validate_inputs(parameter_list)
    return manual_input(
            empty_mass      = InParameters.empty_mass.value     ,
            rocket_cd       = InParameters.rocket_cd.value      ,
            rocket_area     = InParameters.rocket_area.value    ,
            thrust          = InParameters.thrust.value         ,
            propellant_mass = InParameters.propellant_mass.value,
            burn_time       = InParameters.burn_time.value      ,
            airbrake_cd     = InParameters.airbrake_cd.value    ,
            airbrake_area   = InParameters.airbrake_area.value  ,
            drogue_cd       = InParameters.drogue_cd.value      ,
            drogue_area     = InParameters.drogue_area.value    ,
            main_cd         = InParameters.main_cd.value        ,
            main_area       = InParameters.main_area.value      ,
            launch_angle    = InParameters.launch_angle.value   ,
            launch_altitude = InParameters.launch_altitude.value,
            rail_length     = InParameters.rail_length.value    ,
            airbrake_option = InParameters.airbrake_option.value,
            airbrake_opening_logic = InParameters.airbrake_opening_logic.value,
            nozzle_area     = InParameters.nozzle_area.value
        )
end


end
