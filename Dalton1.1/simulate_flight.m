function [T,X] = simulate_flight(f, rkstep, X0)
    n = max(size(f));
%     n = 3;
    T = 0;
    X = X0;
    
    for i = 1:n
        dyna = f{i}; 
        [t,x] = rk4f(dyna, [T(end), rkstep], X(end,:));
        t(1) = [];
        x(1,:) = [];
        T = [T; t];
        X = [X; x];
    end
end