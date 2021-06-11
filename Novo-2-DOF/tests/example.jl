#tudo que precisar ser testado, fazer nessa pasta
include("../base_def.jl")

using .BaseDefinitions

#criação de condições iniciais:

X₀ = StateVector(0, 1294, 0, 0)

aed_drogue = Aed(1.5, 0.7)
drogue = Parachute(aed_drogue, (x::StateVector) -> x.vy < 0)

aed_main = Aed(1.5, 4)
main = Parachute(aed_drogue, (x::StateVector) -> x.y < 1294+300)

motor = Propulsion(2000, 4.5, 6.5)

#mudar a forma de armazenamento da condição de voo
rocket = Rocket(23.5, motor, Aed(0.4, 0.08), drogue, main, "Rail")

rail = Rail(5, 85, 0.03)

env = Environment(9.81, 1.225, rail, 1294)
