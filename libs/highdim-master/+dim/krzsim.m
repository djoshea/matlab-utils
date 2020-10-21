% Krzanowski similarity
function [k,Tm,delta,R] = krzsim(x,y,m)

S1 = cov(x);
S2 = cov(y);

[Q1,D1] = eig(S1);
[Q2,D2] = eig(S2);

Q11 = Q1(:,1:m);
Q12 = Q1(:,(m+1):end);
Q21 = Q2(:,1:m);
Q22 = Q2(:,(m+1):end);

[k,delta,u,v] = princvec(Q11,Q21);
[~,~,u2,v2] = princvec(Q12,Q22);

R = [u u2]*[v';v2'];
Tm = m - k;
%Tm = trace(Q12'*Q21*Q21'*Q12);

function [k,delta,u,v] = princvec(L,M)
N = L'*M*M'*L;
[V,D] = eig(N);
lambda = diag(D);
% Krzanowski similarity
%k = trace(N)
k = sum(lambda);
sl = lambda.^0.5;
delta = real(rad2deg(acos(sl)));

u = L*V;
v = M*M'*u;
