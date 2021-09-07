module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input

include("end_conditions.jl")
using .EndConditions

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
    env = Environment(9.81, 1.225, 340.0, rail, launch_altitude)

    #parametrizar condições de abertura
    drogue = Aed(drogue_cd, drogue_area)
    main = Aed(main_cd, main_area)

    motor = Propulsion(thrust, propellant_mass, burn_time)

    #temporario

    forces_rail = forces_thrusted = forces_ballistic =
        forces_drogue = forces_main =
            (t::Float64, x::StateVector, rocket::Rocket,  env::Environment) ->
            [
                0
                0
            ]

    #fases de voo
    #incluir módulo das dinâmicas aqui
    rail_phase = FlightPhase("rail", forces_rail, rail_end)
    thrusted_phase = FlightPhase("thrusted", forces_thrusted, thrusted_end)
    ballistic_phase = FlightPhase("ballistic", forces_ballistic, ballistic_end)
    drogue_phase = FlightPhase("drogue", forces_drogue, drogue_end)
    main_phase = FlightPhase("main", forces_main, main_end)

    phases = [rail_phase, thrusted_phase, ballistic_phase, drogue_phase, main_phase]
    rocket = Rocket(empty_mass, motor, Aed(rocket_cd, rocket_area),
                     drogue, main, phases)
    
    return X₀, rocket, env
end


end