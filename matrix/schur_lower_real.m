function [Q, T] = schur_lower_real(X)
    % returns lower triangular version of Schur decomposition, satisfying
    % Q * T * Q' == X, columns of Q are Schur bases
    
    [Qa, Ta] = schur(X, 'real');
    
    % permutation matrix to invert columns / rows 
    R = flipud(eye(size(X)));
    
    T = R' * Ta * R';
    Q = Qa * R;
end