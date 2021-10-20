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

"""
    Vsom(k::Float64)

Calcula a velocidade do som a uma altitude h acima do nível do mar.

Reta ajustada a partir dos dados em https://www.engineeringtoolbox.com/elevation-speed-sound-air-d_1534.html
"""
function Vsom(k::Float64)
    return 340.6147266777097 - 0.004065762999474718*k
end 

"""
    rho(k::Float64)

Calcula a densidade do ar a uma altitude h acima do nível do mar.

Curva ajustada a partir de: https://www.engineeringtoolbox.com/standard-atmosphere-d_604.html
"""
function rho(k::Float64)
    return 1.2228930069930133 - 0.00011386139860140224*k + 3.314685314685659e-9*k^2
end 

"""
    g(h::Float64)

Aceleração da gravidade a uma altitude h acima do nível do mar. 
Atualmente a latitude está ajustada para 23,3568°.
Fonte: https://dialnet.unirioja.es/descarga/articulo/5165503.pdf
"""
function g(h::Float64)
    return 9.78875*(1+0.0052790414*sind(23.3568))*(1-2*h/(6.3781*10^6))/(1+0.0052790414/2)
end

end