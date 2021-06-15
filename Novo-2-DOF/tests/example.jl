include("../Rocket_2DOF.jl")

using .Rocket_2DOF
using BenchmarkTools
using Profile
using Plots
gr()

#criação de condições iniciais:

X₀ = StateVector(0, 1294, 0, 0)

aed_drogue = Aed(1.5, 0.7)
drogue = Parachute(aed_drogue, (x::StateVector) -> x.vy < 0)

aed_main = Aed(1.5, 4)
main = Parachute(aed_drogue, (x::StateVector) -> x.y < 1294+300)

motor = Propulsion(2000, 4.5, 6.5)

#mudar a forma de armazenamento da condição de voo
dynas = Dict("inicio" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> X,
             "meio1" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> StateVector(1, 1, 0, 0),
             "meio2" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> StateVector(-1, -1, 0, 0))

ends = Dict("inicio" => (t::Real, X::StateVector, rocket::Rocket,
                           env::Environment) -> true,
            "meio1" => (t::Real, X::StateVector, rocket::Rocket,
                          env::Environment) -> X.y > 400,
            "meio2" => (t::Real, X::StateVector, rocket::Rocket,
                          env::Environment) -> X.y < 0)

rocket = Rocket(23.5, motor, Aed(0.4, 0.08), drogue, main, dynas, ends)

rail = Rail(5, 85, 0.03)

env = Environment(9.81, 1.225, rail, 1294)

# Voo
condition_sequence = Dict{String, String}("inicio" => "meio1",
                                          "meio1" => "meio2",
                                          "meio2" => "fim")

all_X = fullFlight(rocket, env, condition_sequence)

plot1 = plot()
for key in keys(all_X)
    global plot1
    plot1 = scatter!([(X.x, X.y) for X in all_X[key]])
end

res1 = @benchmark solveStage(0, StateVector(0,0,0,0), "inicio", Dict{String, String}("inicio" => "meio", "meio" => "fim"), rocket, env, 0.001)
res2 = @benchmark fullFlight(rocket, env, condition_sequence)

@profile fullFlight(rocket, env, condition_sequence)
