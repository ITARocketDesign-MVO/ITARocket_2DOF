function CD = process_CD(X)
    if ischar(X)
        data = load(X);
        M = data(:,1);
        CD = data(:,2);
    elseif numel(X)==1
        M = [0, 1];
        CD = [X, X];
    end
    m = ceil(max(M)*10)/10;
    M_new = 0:0.01:m;
    CD = interp1(M, CD, M_new, 'linear', 'extrap');
     if isrow(CD)
        CD = CD';
    end
end