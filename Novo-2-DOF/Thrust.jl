include("base_def.jl")

using .BaseDefinitions

function currentThrust(thrust::Float64, t)
    return thrust
end

function currentThrust(thrust::Array{Float64}, t)
    for i in 1:(size(thrust)[1])            
        if t==thrust[i, 2] return thrust[i, 1] end   #thrust[i, 1]=thrust ||||thrust[i, 2]=tempo 
        if (t > thrust[i, 2]) && (t < thrust[i+1, 2])
            return thrust[i, 1]+ (t-thrust[i, 2])*(thrust[i+1,1]-thrust[i,1])/(thrust[i+1,2]-thrust[i,2]) #formula descoberta pela equação da reta
        end
    end
end
#