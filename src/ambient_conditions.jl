module AmbientConditions
export Vsom
"""
    Vsom(h::Float64)

Calcula a velocidade do som a uma altitude h acima do nível do mar.

Reta ajustada a partir dos dados em https://www.engineeringtoolbox.com/elevation-speed-sound-air-d_1534.html
"""
function Vsom(h::Float64)
    return sqrt(1.4 * 8314.32 * (288.15 - 0.0065 * (6356766 * h) / (6356766 + h)) / 28.9644)
end

"""
    rho(h::Float64)

Calcula a densidade do ar a uma altitude h acima do nível do mar.

Curva encontrada no livro: "U.S Standard Atmosphere 1976"
"""
function rho(h::Float64)
    return Patm(h) * 28.9644/(8314.32 * (288.15 - 0.0065 * (6356766 * h) / (6356766 + h)))
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

"""
    Patm(h::Float64)

Calcula a pressão atmosférica a uma altitude h acima do nível do mar até 11,02 km.

Curva encontrada no livro: "U.S Standard Atmosphere 1976"
"""
function Patm(h::Float64)
    return 101325 * (288.1 / (288.1 - 0.0065 * (6356766 * h / (6356766 + h)))) ^ 
            (9.80665 * 28.9644 / (8.31432 * 1000 * (- 0.0065)))
end

end
