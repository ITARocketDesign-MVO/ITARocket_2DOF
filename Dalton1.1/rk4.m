function [T,X] = rk4(dyna, tspan, X0)
    % Chamando a variavel global
    global ROCKET
    
    T = tspan(1);
    h = tspan(2);
    
    X = X0;
    
    % Vetor de funcoes de Fases de Voo.
    n = max(size(dyna));
    
    h0 = ROCKET.Altitude;
        
    for j = 1:n
        f = dyna{j};
        % Inicializa a Fase do voo.
        ROCKET.Condition = true;
        
        % Copia a Informacao da massa no instante T
        m = ROCKET.Empty_mass;
        if j==4
            CD = ROCKET.CD_drogue;
            S = ROCKET.Area_drogue;
        elseif j==5
            CD = ROCKET.CD_main;
            S = ROCKET.Area_main;
        else
            CD = process_CD(ROCKET.CD);
            S = ROCKET.Area;
        end
        
        % t de cada nova fase eh baseado no ultimo "t" da fase anterior.
        t = T(end);
        x = X(end, :);
        
        while ROCKET.Condition
            a = h*f( t(end, 1)       , x(end,:)        , m, h0, S, CD); %k1.h
            b = h*f( t(end, 1)  + h/2, x(end,:) + 0.5*a, m, h0, S, CD); %k2.h
            c = h*f( t(end, 1)  + h/2, x(end,:) + 0.5*b, m, h0, S, CD); %k3.h
            % Proximo passo no tempo 
            t(end+1, 1) = t(end, 1) + h;
            d = h*f( t(end, 1)       , x(end,:) + c    , m, h0, S, CD);
            x(end+1,:) = x(end,:) + (a + 2*(b + c) + d)/6;
        end
        
        t(1) = [];
        x(1,:) = [];
        T = [T; t];
        X = [X; x];
        
    end
end