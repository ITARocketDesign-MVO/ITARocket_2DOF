module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input

include("dynamics.jl")
using .Dynamics

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
    env = Environment(x -> 9.81, x-> 1.225, x -> 340.0, rail, launch_altitude)

    #parametrizar condições de abertura
    drogue = Aed(drogue_cd, drogue_area)
    main = Aed(main_cd, main_area)

    motor = Propulsion(thrust, propellant_mass, burn_time)

    rail_end = thrusted_end = ballistic_end = drogue_end = main_end =
            (t::Float64, X::StateVector, rocket::Rocket, env::Environment) -> true

    #fases de voo
    #incluir módulo das dinâmicas aqui
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


end
