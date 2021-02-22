function [CD] = computeCD(X,f)
%COMPUTECD Summary of this function goes here
%   Detailed explanation goes here
    V = sqrt(X(:,3).^2 + X(:,4).^2);
    a = soundspeed(X(:,2));
    M = V/a;
    CD = fnval(f,M);
end

