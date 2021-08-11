
#tudo que precisar ser testado, fazer nessa pasta

include("../input.jl")
include("../rail_dynamic.jl")
include("../Thrust.jl")


using .BaseDefinitions
using .Inputs
#criação de condições iniciais:

X₀, rocket, env = manual_input(
    empty_mass = 23.5,
    rocket_cd = 0.4,
    rocket_area = 0.08,
    thrust = 2000,
    propellant_mass = 4.5,
    burn_time = 6.74,
    drogue_cd = 1.5,
    drogue_area = 0.7,
    main_cd = 1.5,
    main_area = 4,
    launch_angle = 85,
    launch_altitude = 1294,
    rail_length = 5
)


#mudar a forma de armazenamento da condição de voo
dynas = Dict("inicio" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> X,
             "meio1" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> StateVector(1, 1, 0, 0),
             "meio2" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> StateVector(1, -1, 0, 0))

ends = Dict("inicio" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> true,
            "meio1" => (t::Real, X::StateVector, rocket::Rocket,
                          env::Environment) -> X.y > 400,
            "meio2" => (t::Real, X::StateVector, rocket::Rocket,
                          env::Environment) -> X.y < 0)

rocket = Rocket(23.5, motor, Aed(0.4, 0.08), drogue, main, dynas, ends)


currentThrust([1.0 1.0; 2 2; 3 3; 4 4; 5 5; 6 6], 3.5)


env = Environment(9.81, 1.225, rail, 1294)

# Voo
condition_sequence = Dict{String, String}("inicio" => "meio1",
                                          "meio1" => "meio2",
                                          "meio2" => "fim")

all_X = fullFlight(rocket, env, condition_sequence)



