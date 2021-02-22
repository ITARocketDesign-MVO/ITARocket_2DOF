function [Dx,Dy] = aed(h, vx, vy, S, CD)
    
    rho = 1.224265 - 1.16122e-4*h + 3.69108e-9*h^2;
    
    b = 0.5*rho*S*CD;
    Dx = b*vx^2;
    Dy = b*vy^2;
end