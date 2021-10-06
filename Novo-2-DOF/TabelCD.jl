function Leitcd(arquivo::String)
    vel = [];   #vetor nulo
    cd = [];    #vetor nulo
    x = open(arquivo,"r") do x2
        for i in eachline(x2) 
            numeros = rsplit(i, "   ")                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
            push!(vel, parse(Float64, numeros[2]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(cd, parse(Float64, numeros[3]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
       end                                             #no caso transforma string para float
    end
    Cd = hcat(vel, cd);  #concatena duas matrizes no  sentido das colunas 
    return Cd;
end