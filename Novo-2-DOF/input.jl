module Inputs
#módulo para colocar os parâmetros do foguete
using ..BaseDefinitions
export manual_input

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
    X₀ = StateVector(0, launch_altitude, 0, 0)
    
    rail = Rail(rail_length, launch_angle, 0.03)

    #mudar para funções
    env = Environment(9.81, 1.225, rail, launch_altitude)

    #parametrizar condições de abertura
    drogue = Parachute(Aed(drogue_cd, drogue_area),
                    (x::StateVector) -> x.vy < 0)
    main = Parachute(Aed(main_cd, main_area),
                    (x::StateVector) -> x.y <= launch_altitude+300)

    motor = Propulsion(thrust, propellant_mass, burn_time)

    rocket = Rocket(empty_mass, motor, Aed(rocket_cd, rocket_area),
                     drogue, main,
                     "MUDAR DEPOIS", Dict(), Dict())
    
    return X₀, rocket, env
end


end