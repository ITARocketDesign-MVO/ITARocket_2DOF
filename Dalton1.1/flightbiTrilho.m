function [deltat, T, X, rocket, prop, trilho] = flightbiTrilho(plot_logical, stepsize)

    % Dalton Felipe de Menezes AESP 15
    % ITA Rocket Design
    % Última versão: 2015-09-04 
    % Adaptado para o 6DOF do peixoto em 06/08/2019
    % Adicionado opções para empuxo e CD constantes em 07/09/2019 por Rafael Celente AESP 23 
    % Revisor: Octavio Mathias AER 19
    
    % Programa de simulação de trajetória bidimensional da equipe ITA
    % Rocket Design. O programa permite o cálculo da trajetória nominal
    % baseado em inputs de outros subsistemas (AED, PRP, EST, etc), bem
    % como nos dados conhecidos da competição (Altitude local, comprimento
    % de trilho e outros).
    
    % Variáveis globais a serem acessados pelas outras funções. O uso de
    % variáveis globais é indesejado, porém foi a melhor opçãoo encontrada
    % até agora, tanto em questão de eficiência quanto de clareza de
    % código. Por outro lado, o uso de variáveis globais requer o domínio
    % completo do programa e dificulta a modularidade dos programas.
    
    tic
    global ROCKET
    global PROP
    global RAIL
    global SIM
    global AED
    
    % Definição dos argumentos da função caso não tenham sido inicializados
    default_stepsize = 0.01;
    if nargin == 0
        plot_logical = true;
        stepsize = default_stepsize;
    elseif nargin == 1
        stepsize = default_stepsize;
    end
    %mextra = 4;
    %mmotor = 3.610;
    ROCKET.Empty_mass = 23;              % Massa vazia - sem propelente - do foguete       (kg)
    ROCKET.Area = (pi/4)*(0.1524)^2;     % Área máxima transversal do foguete (m^2)
    ROCKET.Area_drogue = (pi*(0.8)^2)/4;        % Área do paraquedas Drogue   (m^2)
    ROCKET.Area_main = (pi*(4)^2) / 4;          % Área do paraquedas Main     (m^2)
    ROCKET.Altitude = 1294;              % Altitude de lançamento        (m)
    ROCKET.G = -grav(ROCKET.Altitude);   % Gravidade local           (m/s^2)
    ROCKET.CD = 0.5;                     % CD do foguete ou nome do arquivo 
    ROCKET.CD_drogue = 1.5;              % Coef. de arrasto do Drogue
    ROCKET.CD_main = 1.5;                % Coef. de arrasto do Main
    
    % Motor Input Analitico.
    Efficiency = 0.95;
    Isp = 224*Efficiency;
    
    PROP.Mass = 5.8;                              % Massa total de propelente    (kg)
    PROP.Burn_time = 5.5;                         % Tempo de queima do propelente (s)
    PROP.Thrust = 'Empuxo_completo.dat';          % Empuxo do motor. Pode ser uma constante ou uma tabela.
    PROP.Table = 0;
    
    if (ischar(PROP.Thrust))
        PROP.Table = 1;
    end
    
    if (PROP.Table)
        % Interpolacao dos dados de Tracao!
        dataThrust = load(PROP.Thrust);
        tThrust = dataThrust(:,1);
        ForceThrust = dataThrust(:,2);
        % criar uma funcao de interpolacao
        PROP.Fiter = csapi(tThrust,ForceThrust);
    else
        PROP.Fiter = PROP.Thrust;
    end
    
    %Dados aerodinâmica
    AED.CD_Mach = 0.5;                  % CD por Mach. Pode ser um escalar ou uma tabela.
    AED.Table = 0;
    
    
    if (ischar(AED.CD_Mach))
        AED.Table = 1;
    end
    
    if (AED.Table)
        % Interpolação dos dados de Aerodinamica
        dataDrag = load(AED.CD_Mach);
        dataMach = dataDrag(:,1);
        dataCD = dataDrag(:,2);
        % criar uma funcao de interpolacao
        AED.Fiter = csapi(dataMach,dataCD);
    else
        AED.Fiter = AED.CD_Mach;
    end
    
    
    %PROP.Thrust = Isp*(-ROCKET.G)*PROP.Mass/PROP.Burn_time;                 
    
    RAIL.Friction = 0.3;                % Coef. de atrito do trilho
    RAIL.Angle = 85*pi/180;             % INPUT âng. de elevação de lançam. em  (�)
    RAIL.Length = 5.4864;               % Comprimento do trilho         (m)
    
    SIM.RKSTEP = stepsize;              % Passo de integracao RKutta da simulação  (s)
    SIM.X0 = [0 ROCKET.Altitude 0 0];   % Cond. iniciais   (X_m, Y_m, Vx_m/s, Vy_m/s)
    
    % Array das células contendo as funções das dinâmicas da simulação 
    dyna = {@dyna_rail};
        
    % [VectorTempo, VectorX_altura_Velocidade] =
    % rk4(@function,[timeInstant,stepSize,initialCondition]
    [T,X] = rk4(dyna, [0, SIM.RKSTEP], SIM.X0);
    
    % Subtrair altitude local para obter a altitude relativa ao lançamento
    X(:,2) = X(:,2) - ROCKET.Altitude;
    rocket = ROCKET;
    prop = PROP;
    trilho = RAIL;
    
    disp('Velocidade de saida: ');
    disp(RAIL.Vel_end);
    % Plotar gr�ficos caso desejado
    if plot_logical
        flight_plot(T, X)
    end
    deltat = toc;
    %max(X(:,2)) % Mostra apogeu na janela de comando.
    %max(X(:,4))
end
