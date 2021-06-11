include("base_def.jl")

using .BaseDefinitions
Cd=[]
function currentCd(X::StateVector, Cd::Float64)
    return Cd
end

function currentCd(X::StateVector, Cd::Array{Float64})
    v=sqrt(X.vx^2+X.vy^2)                #velocidade do foguete
     
    for i in 1:(length(Cd)/2)             #length(Cd)/2 pois o Cd é uma matriz n por 2 (n linha e 2 colunas) e o comprimento dessa matriz seria 2n, e queremos percorrer apenas as linhas (n linhas) 
        if v==Cd[i, 2] return Cd[i, 1] end   #Cd[i, 1]=Cd ||||Cd[i, 2]=velocidade 
        if v>Cd[i, 2] & v<Cd[i+1, 2]
            return Cd[i, 1]+ (v-Cd[i, 2])*(Cd[i+1,1]-Cd[i,1])/(Cd[i+1,2]-Cd[i,2]) #formula descoberta pela equação da reta
        end
    end
end