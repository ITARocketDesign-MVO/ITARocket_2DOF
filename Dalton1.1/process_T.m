function T = process_T(X)
global PROP
global SIM

    if ischar(X)
        data = load(X);
        t = data.thrust_data(:,1);
        T = data.thrust_data(:,2);
    elseif numel(X)==1
        t = [0, PROP.Burn_time]; %intervalo de tempo
        T = [X, X];
    end
    m = ceil(max(t)*10)/10;
    t_new = 0:(SIM.RKSTEP/2):m; %regular o passo
    T = interp1(t, T, t_new, 'linear', 'extrap');
     if isrow(T)
        T= T';
    end
end