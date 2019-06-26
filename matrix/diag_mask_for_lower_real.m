function mask = diag_mask_for_lower_real(T, eig_mask)

N = size(T, 1);

if nargin < 2
    eig_mask = true(N, 1);
end

mask = false(N, N);

eig = ordeig_lower(T);
iE = 1;
while iE <= N
    if ~isreal(eig(iE))
        % complex eigenvalue pair
        if eig_mask(iE) || eig_mask(iE+1)
            % include off diagonal terms
            mask(iE:iE+1, iE:iE+1) = true;
        end
        iE = iE + 2; % skip my conjugate pair
    else
        % real eigenvalue
        if eig_mask(iE)
            % include only diagonal term
            mask(iE, iE) = true;
        end
        iE = iE + 1;
    end
end

end