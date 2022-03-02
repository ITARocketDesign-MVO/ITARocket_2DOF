module Interpolators

using ....BaseDefinitions
export currentCd, currentThrust

function currentCd(X::StateVector, rocket::Rocket, env::Environment)
    return currentCd(X, rocket.flight_phases[1].aed.Cd, env) #se a tabela de CD ficar guardada na fase 1
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

function currentThrust(t::Float64, X::StateVector, rocket::Rocket, env::Environment)
    currentThrust(t, rocket.propulsion.thrust) - env.Patm(X.y) * rocket.flight_phases
    return currentThrust(t, rocket.propulsion.thrust)
end

function currentThrust(t::Float64, thrust::Real)
    return thrust
end

function currentThrust(t::Float64, thrust::Matrix{<:Real})
    for i in 1:(size(thrust)[1])            
        if t == thrust[i, 1] 
            return thrust[i, 2]   #thrust[i, 1]=empuxo ||||thrust[i, 2]=tempo 

        elseif t > thrust[end, 1]
            return 0.0
            
        elseif (t > thrust[i, 1]) && (t < thrust[i+1, 1])
            return thrust[i, 2] + (t - thrust[i, 1]) *
                 (thrust[i+1,2] - thrust[i,2]) / (thrust[i+1,1] - thrust[i,1])
        end

    end
end



end