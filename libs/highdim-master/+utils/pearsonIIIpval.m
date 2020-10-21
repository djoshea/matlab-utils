%    Calculate p-value for statistic of the form trace(A*B) using Pearson 
%    Type III approximation using exact first three moments of the
%    permutation distribution
function [pval,stat] = pearsonIIIpval(A,B,stat)

if nargin < 3
   stat = sum(sum(A.*B));
end

% Exact moments of permutation distribution
[mu,sigma2,skew] = utils.permMoments(A,B);

stat = (stat - mu)/sqrt(sigma2);

if skew >= 0
   pval = gamcdf(stat - (-2/skew),4/skew^2,skew/2,'upper');
else
   as = abs(skew);
   pval = gamcdf(skew/as*stat + 2/as,4/skew^2,as/2);
end
