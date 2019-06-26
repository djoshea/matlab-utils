function [Q, T] = schur_lower_real(X)
    [Qa, Ta] = schur(X, 'real');
    
    % permutation matrix to invert columns / rows 
    R = flipud(eye(size(X)));
    
    T = R' * Ta * R';
    Q = Qa * R;
end