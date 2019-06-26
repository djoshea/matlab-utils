function [Q, T] = schur_lower_real_zeroeiglast(X)
    [Qa, Ta] = schur(X, 'real');
    
    % sort eigenvalues by descending abs 
    L = ordeig(Ta);
    [~, sortIdx] = sort(abs(L), 'descend');

    % reorder the Schur decomp accordingly
    [Qs,Ts] = ordschur(Qa, Ta, sortIdx);
    
    % permutation matrix to invert columns / rows 
    R = flipud(eye(size(X)));
    T = R' * Ts * R';
    Q = Qs * R;
end