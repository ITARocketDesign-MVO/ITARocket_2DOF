function X_p = dyna_thrusted(t, X, m, ~, S, CD)
    global PROP
    global AED
    
    y  = X(2);
    vx = X(3);
    vy = X(4);
    
    theta = atan2(vy,vx);
    ct = cos(theta);
    st = sin(theta);
    
    t_burn = PROP.Burn_time;
    
    if t > t_burn
        global ROCKET
        ROCKET.Condition = false;
        ROCKET.Velocity_max = sqrt(vx^2 + vy^2);
        ROCKET.Mach = ROCKET.Velocity_max/soundspeed(y);
    end
    
    m = m + PROP.Mass*(1 - t/t_burn);
    g = -grav(y);
    
    if (AED.Table)
        CD = dragcoeff(X, CD);
    else
        CD = AED.Fiter;
    end
    
    if (PROP.Table)
        T = Tnotempo(t);
    else
        T = PROP.Fiter;
    end
    Tx = T*ct;
    Ty = T*st;
    
    [Dx, Dy] = aed(y, vx, vy, S, CD);
    
    vx_p = (Tx - sign(vx)*Dx)/m;
    vy_p = (Ty - sign(vy)*Dy)/m + g;
    
    X_p = [vx, vy, vx_p, vy_p];
end