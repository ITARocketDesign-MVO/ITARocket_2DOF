include("base_def.jl")

using .BaseDefinitions

function currentThrust(X::StateVector, thrust::Float64)
    return thrust
end

function currentThrust(X::StateVector, thrust::Array{Float64})
    v=sqrt(X.vx^2+X.vy^2)                 #velocidade do foguete
     
    for i in 1:(size(thrust)[1])            
        if v==thrust[i, 2] return thrust[i, 1] end   #thrust[i, 1]=thrust ||||thrust[i, 2]=velocidade 
        if (v > thrust[i, 2]) && (v < thrust[i+1, 2])
            return thrust[i, 1]+ (v-thrust[i, 2])*(thrust[i+1,1]-thrust[i,1])/(thrust[i+1,2]-thrust[i,2]) #formula descoberta pela equação da reta
        end
    end
end