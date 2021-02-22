for i = 1:1027
 if abs(estados(12,i)-(5.4864*sin(deg2rad(85))))<0.5
     i    
 end
end


index=find(abs(estados(12,i)-(5.4864*sin(deg2rad(85))))<0.5)

velocidade_saida=sqrt(estados(4,13)^2+estados(5,13)^2+estados(6,13)^2)