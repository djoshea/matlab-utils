function E = ordeig_lower(T)
% exactly like ordeig but for lower triangular T produced by schur_lower_real
    R = flipud(eye(size(T)));
    T = R' * T * R';
    
    E = ordeig(T);
end