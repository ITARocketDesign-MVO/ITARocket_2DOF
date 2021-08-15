vel = []    #vetor nulo
cd = []     #vetor nulo

x = open("CDvMach.dat","r") do x
    for i in eachline(x) 
        numeros = rsplit(i, "   ")                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
        push!(vel, parse(Float64, numeros[2]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
        push!(cd, parse(Float64, numeros[3]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
    end                                             #no caso transforma string para float
end


Cd = hcat(vel, cd)  #concatena duas matrizes no  sentido das colunas 

#Problema na parte de Propulsion e de thrust, exemplo, dyna_ballistic e de thrust