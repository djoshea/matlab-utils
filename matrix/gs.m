function [Q,R] = gs(X)
    % Classical Gram-Schmidt.  [Q,R] = gs(X);
    % G. W. Stewart, "Matrix Algorithms, Volume 1", SIAM, 1998.
    % https://blogs.mathworks.com/cleve/2016/07/25/compare-gram-schmidt-and-householder-orthogonalization-algorithms/?doing_wp_cron=1646522068.3891079425811767578125
    [n,p] = size(X);
    Q = zeros(n,p);
    R = zeros(p,p);
    for k = 1:p
        Q(:,k) = X(:,k);
        if k ~= 1
            R(1:k-1,k) = Q(:,k-1)'*Q(:,k);
            Q(:,k) = Q(:,k) - Q(:,1:k-1)*R(1:k-1,k);
        end
        R(k,k) = norm(Q(:,k));
        Q(:,k) = Q(:,k)/R(k,k);
     end
end