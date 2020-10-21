% TODO
%  o Looks like the definition of MMD in Gretton's publicly available code
%    differs slightly from their paper (re. the diagonal terms)

function stat = mmd_(K,L,KL,m,n,biased)

if biased
   stat = (sum(K(:))+m)/m^2 + (sum(L(:))+n)/n^2 - 2*sum(KL(:))/m/n;
else
   stat = sum(K(:))/m/(m-1) + sum(L(:))/n/(n-1) - 2*sum(KL(:))/m/n;
end