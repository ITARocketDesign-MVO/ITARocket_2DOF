function [T,X] = rk4f(f, t, X0)
    global ROCKET
    T = t(1);
    h = t(2);
    i = 1;
    X(1,:) = X0;
    ROCKET.Condition = true;
    
    while ROCKET.Condition
        T(i+1, 1) = T(i, 1) + h;
        a = h*f( T(i, 1)       , X(i,:)        );
        b = h*f( T(i, 1)  + h/2, X(i,:) + 0.5*a);
        c = h*f( T(i, 1)  + h/2, X(i,:) + 0.5*b);
        d = h*f( T(i+1, 1)     , X(i,:) + c    );
        X(i+1,:) = X(i,:) + (a + 2*(b + c) + d)/6;
        i = i + 1;
    end
end