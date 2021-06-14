include("../Rocket_2DOF.jl")

using .Rocket_2DOF
using BenchmarkTools

#criação de condições iniciais:

X₀ = StateVector(0, 1294, 0, 0)

aed_drogue = Aed(1.5, 0.7)
drogue = Parachute(aed_drogue, (x::StateVector) -> x.vy < 0)

aed_main = Aed(1.5, 4)
main = Parachute(aed_drogue, (x::StateVector) -> x.y < 1294+300)

motor = Propulsion(2000, 4.5, 6.5)

#mudar a forma de armazenamento da condição de voo
dynas = Dict("example" => (X::StateVector, t, rocket::Rocket, env::Environment) -> (1,2))
ends = Dict("example" => (X::StateVector, t, rocket::Rocket, env::Environment) -> X.y > 400)
rocket = Rocket(23.5, motor, Aed(0.4, 0.08), drogue, main, "example", dynas, ends)
rocket.dynamics[rocket.condition]

rail = Rail(5, 85, 0.03)

env = Environment(9.81, 1.225, rail, 1294)
