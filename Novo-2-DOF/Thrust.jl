include("base_def.jl")

using .BaseDefinitions

function currentThrust(X::StateVector, thrust::Float64)
    return thrust
end

function currentThrust(X::StateVector, thrust::Array{Float64})
    for i in 1:(size(thrust)[1])            
        if t==thrust[i, 2] return thrust[i, 1] end   #thrust[i, 1]=thrust ||||thrust[i, 2]=tempo 
        if (t > thrust[i, 2]) && (t < thrust[i+1, 2])
            return thrust[i, 1]+ (t-thrust[i, 2])*(thrust[i+1,1]-thrust[i,1])/(thrust[i+1,2]-thrust[i,2]) #formula descoberta pela equação da reta
        end
    end
end