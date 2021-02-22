function [X_p] = dyna_rail(t, X, m, h0, S, CD)
    % Chamando as Variaveis globais.
    global PROP
    global RAIL
    global AED
    
    x  = X(1);
    y  = X(2);
    vx = X(3);
    vy = X(4);
    
    theta = RAIL.Angle;
    ct = cos(theta);
    st = sin(theta);
    
    dist = norm([x, y-h0], 2);
    
    if dist > RAIL.Length
        global ROCKET
        ROCKET.Condition = false;
        RAIL.Vel_end = sqrt(vx^2 + vy^2);
        RAIL.t_end = t;
        RAIL.X0 = x;
        RAIL.Y0 = y;
    end
    
    m = m + PROP.Mass*(1 - t/PROP.Burn_time);
    
    %T = process_T(PROP.Thrust);
    if (PROP.Table)
        T = fnval(PROP.Fiter,t);
    else
        T = PROP.Fiter;
    end
    Tx = T*ct;
    Ty = T*st;
    
    if vy > 0
        mu = RAIL.Friction;
        g = grav(y);
        
        Ax = -g*ct*(st+ct*mu);
        Ay = g*ct*(ct-st*mu);
        
        gx = Ax;
        gy = -g + Ay;
    else
        gx = 0;
        gy = 0;
    end
    
    %CD = dragcoeff(X, CD);
    if (AED.Table)
        CD = computeCD(X,AED.Fiter);
    else
        CD = AED.Fiter;
    end
    
    [Dx, Dy] = aed(y, vx, vy, S, CD);
    
    vx_p = (Tx(1) - sign(vx)*Dx)/m + gx;
    vy_p = (Ty(1) - sign(vx)*Dy)/m + gy;
    X_p = [vx, vy, vx_p, vy_p];
end