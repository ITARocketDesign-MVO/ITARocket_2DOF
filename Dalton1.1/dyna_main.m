function X_p = dyna_main(~, X, m, h0, S, CD)
    
    y  = X(2);
    vx = X(3);
    vy = X(4);
    
    if y <= h0
        global ROCKET
        ROCKET.Condition = false;
    end
    g = -grav(y);
    
    [Dx, Dy] = aed(y, vx, vy, S, CD);
    
    vx_p = -sign(vx)*Dx/m;
    vy_p = -sign(vy)*Dy/m + g;
    
    X_p = [vx, vy, vx_p, vy_p];
end