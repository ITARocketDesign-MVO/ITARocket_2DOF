function Vsom(k::Float64)
    h = [];   #vetor nulo
    vsom = [];    #vetor nulo
    x = open("dados_dens_vel.txt","r") do x2
        for i in eachline(x2) 
            numeros = rsplit(i, "               ")                  #Separa a string em um vetor de string (obs.: separa a string de acordo com "   ")
            push!(h, parse(Float64, numeros[1]));     #Push insere um elemento na próxima linha de uma matriz com uma coluna, push!(matriz, elemento)
            push!(vsom, parse(Float64, numeros[3]));      #o elemento é o parse(...), parse serve pra transformar: parse(o formato que tu quer, o que você quer transformar)
       end                                             #no caso transforma string para float
    end
    vsomm = hcat(h, vsom);  #concatena duas matrizes no  sentido das colunas 

    for i in 1:(size(vsomm)[1])             #length(Cd)/2 pois o Cd é uma matriz n por 2 (n linha e 2 colunas) e o comprimento dessa matriz seria 2n, e queremos percorrer apenas as linhas (n linhas) 
        if k==vsomm[i, 1] return vsomm[i, 2] end   #Cd[i, 1]=Cd ||||Cd[i, 2]=velocidade 
        if (k > vsomm[i, 1]) && (k < vsomm[i+1, 1])
            return vsomm[i, 2]+ (k-vsomm[i, 1])*(vsomm[i+1,2]-vsomm[i,2])/(vsomm[i+1,1]-vsomm[i,1]) #formula descoberta pela equação da reta
        end
        if (k > vsomm[size(vsomm)[1], 1]) return ro[6, 3] + (k - ro[6, 1])*(ro[size(ro)[1], 3]-ro[6, 3])/ro[6, 1] end
    end

end