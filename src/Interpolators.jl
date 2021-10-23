module Interpolators

using ....BaseDefinitions
export currentCd, currentThrust

function currentCd(X::StateVector, rocket::Rocket, env::Environment)
    return currentCd(X, rocket.aed.Cd, env)
end

function currentCd(X::StateVector, Cd::Real, env::Environment)
    return Cd
end

function currentCd(X::StateVector, Cd::Matrix{Float64}, env::Environment)
    v=sqrt(X.vx^2+X.vy^2)                 #velocidade do foguete
     
    N_mach = v / env.v_sound(X.y + env.launch_altittude)
    
    for i in 1:(size(Cd)[1])
        if N_mach==Cd[i, 2] return Cd[i, 1] end   #Cd[i, 1]=Cd ||||Cd[i, 2]=número de Mach 
        
        if (N_mach > Cd[i, 2]) && (N_mach < Cd[i+1, 2])
            return Cd[i, 1] + (N_mach - Cd[i, 2]) * 
                    (Cd[i+1,1] - Cd[i,1]) / (Cd[i+1,2] - Cd[i,2]) #formula descoberta pela equação da reta
        end
    end

    #N_mach maior que o último da tabela
    return Cd[end, 1]
end

function currentThrust(t::Float64, rocket::Rocket)
    return currentThrust(t, rocket.propulsion.thrust)
end

function currentThrust(t::Float64, thrust::Real)
    return thrust
end

function currentThrust(t::Float64, thrust::Matrix{Float64})
    for i in 1:(size(thrust)[1])            
        if t == thrust[i, 2] return thrust[i, 1] end   #thrust[i, 1]=empuxo ||||thrust[i, 2]=tempo 
        
        if (t > thrust[i, 2]) && (t < thrust[i+1, 2])
            return thrust[i, 1] + (t - thrust[i, 2]) * 
                (thrust[i+1,1] - thrust[i,1]) / (thrust[i+1,2] - thrust[i,2])
        end
    end
end



end