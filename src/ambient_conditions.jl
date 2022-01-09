module AmbientConditions
export Vsom
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
