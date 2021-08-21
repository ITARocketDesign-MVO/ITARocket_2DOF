function ro(k::Float64)
    return 1.2228930069930133 - 0.00011386139860140224*k + 3.314685314685659e-9*k^2
end 

#= COMO DESCOBRIR A FÓRMULA:
    #primeiro: adicionar os pacotes (packages)
    #using Pkg
    #Pkg.add("Plots") ;; Pkg.add("LsqFit")

using Plots  
using LsqFit
h = [];         #vetor nulo
pho = [];      #vetor nulo
x = open("pho_standard.txt","r") do x2      #onde estão os dados
    for i in eachline(x2) 
        numeros = rsplit(i, "\t")               #Separa a string em um vetor de string (obs.: separa a string de acordo com o tab "\t")
                                                #parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
        if parse(Float64, numeros[1])<10001     #numeros[1] se refere à altura, numeros[5] à densidade do ar (pho)
                                                #Se a altura for superior a 10km paramos a coleta de dados (porque deixa de ser próximo de uma reta)              
            push!(h, parse(Float64, numeros[1]));   #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(pho, parse(Float64, numeros[5]));#o elemento é o parse(...), 
        else break end
   end
end
plot(h, pho)       #plota o graficco

#AGORA BUSCAR A FUNÇÃO DO GRÁFICO

using LsqFit
#ajustar uma reta
@. model(x, p) = p[3]*x^2 + p[2]*x + p[1]    #O modelo da reta, "p" é um vetor contendo os termos do gráfico

#estimativa dos parâmetros
p0 = [10.0, 10.0, 10.0]               #p0 é o polinomio que contém de fato os termos numéricos, primeiro fazemos um "chute", no caso 10 e 10
fit = curve_fit(model, h, pho, p0)

t=0:1:10000
plot!(t, model(t, fit.param))   #plotamos o novo grafico pra ver se ficou legal

println(fit.param)              #Vemos quais são os valores numéricos dos termos 
println(sum(fit.resid.^2))      #soma dos quadrados dos erros (para garantir que é baixo)

#FONTE DOS DADOS:https://www.engineeringtoolbox.com/standard-atmosphere-d_604.html
#Standard atmosphere
=#
