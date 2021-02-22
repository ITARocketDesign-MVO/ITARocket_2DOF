function X_p = dyna_ballistic(~, X, m, h0, S, CD)
    global AED
    y  = X(2);
    vx = X(3);
    vy = X(4);
    
    if vy < 0
        global ROCKET
        ROCKET.Condition = false;
        ROCKET.Apogee = X(2) - h0 - 3048;
    end
    
    g = -grav(y);
    
    %CD = dragcoeff(X, CD);
    if (AED.Table)
        CD = computeCD(X,AED.Fiter);
    else
        CD = AED.Fiter;
    end
    
    [Dx, Dy] = aed(y, vx, vy, S, CD);
    
    vx_p = -sign(vx)*Dx/m;
    vy_p = -sign(vy)*Dy/m + g;
    
    X_p = [vx, vy, vx_p, vy_p];
end