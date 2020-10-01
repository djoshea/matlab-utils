function [lambda,m,delta,sigma,c]=gx2_params_norm_quad(mu,v,quad)
% A quadratic form of a normal variable is distributed as a generalized
% chi-squared. This function takes the normal parameters and the quadratic
% coeffs and returns the parameters of the generalized chi-squared.

% standardize the space
q2=sqrtm(v)*quad.q2*sqrtm(v);
q1=sqrtm(v)*(2*quad.q2*mu+quad.q1);
q0=mu'*quad.q2*mu+quad.q1'*mu+quad.q0;

[R,D]=eig(q2);
d=diag(D)';
b=(R'*q1)';
b2=b.^2;

[lambda,~,ic]=unique(nonzeros(d)'); % unique non-zero eigenvalues
m=accumarray(ic,1)'; % total dof of each eigenvalue
delta=arrayfun(@(x) sum(b2(d==x)),lambda)./(4*lambda.^2); % total non-centrality for each eigenvalue
sigma=sum(b(~d));
c=q0-sum(lambda.*delta);
