#tudo que precisar ser testado, fazer nessa pasta

#exemplo: teste de criação das structs-base
include("../base_def.jl")

using .BaseDefinitions

#overload e criação do vetor de estados
x = StateVector(1,2,3,4,5)
y = 2*x
y+x

#paraquedas com função de abertura
aed = Aed(1.5, 4.5)
drogue = Parachute(aed, (x::StateVector) -> (x.vy < 0))
drogue.activate_condition(x)

