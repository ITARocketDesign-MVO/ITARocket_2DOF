function CD = dragcoeff(X, CD)
    V = sqrt(X(:,3).^2 + X(:,4).^2);
    a = soundspeed(X(:,2));
    M = V/a;
    n = floor(M*100) + 1;
    alpha = n/100-M;
    CD = CD(n)*alpha + CD(n+1)*(1-alpha);
end