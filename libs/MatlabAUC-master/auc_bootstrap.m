% AUC_BOOTSTRAP               Bootstrap test if AUC is different from H0
% 
%     p = auc_bootstrap(data,nboot,flag,H0);
%
%     INPUTS
%     data  - Nx2 matrix [t , y], where
%             t - a vector indicating class value (>0 positive class, <=0 negative)
%             y - score value for each instance
%
%     OPTIONAL
%     nboot - specifies # of resamples, default=1000
%     flag  - 'both' tests AUC is not H0 (two-tailed, DEFAULT)
%             'upper' tests AUC is not larger than H0 (right-tailed)
%             'lower' tests AUC is not smaller than H0 (left-tailed)
%     H0    - null hypothesis (default=0.5)
%
%     OUTPUTS
%     p     - p-value
% 
%
%     EXAMPLES
%     % Classic binormal ROC. 100 samples from each class, with a 0.5 mean separation
%     % between the classes.
%     >> mu = 0.5;
%     >> y = [randn(50,1)+mu ; randn(50,1)];
%     >> t = [ones(50,1) ; zeros(50,1)];
%     >> p = auc_bootstrap([t,y],2000) % two-tailed
%     >> p = auc_bootstrap([t,y],2000,'lower')
%     >> p = auc_bootstrap([t,y],2000,'upper')
%     >> trueA = normcdf(mu/sqrt(1+1^2))
%     >> p = auc_bootstrap([t,y],2000,'both',trueA)
%     

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found on GitHub:
%     https://github.com/brian-lau/MatlabAUC
%
%     REVISION HISTORY:
%     brian 03.08.08 written

function p = auc_bootstrap(data,nboot,flag,H0)

if size(data,2) ~= 2
   error('Incorrect input size in AUC_BOOTSTRAP!');
end

if ~exist('H0','var')
   H0 = 0.5;
elseif isempty(H0)
   H0 = 0.5;
end

if ~exist('flag','var')
   flag = 'both';
elseif isempty(flag)
   flag = 'both';
else
   flag = lower(flag);
end

if ~exist('nboot','var')
   nboot = 1000;
elseif isempty(nboot)
   nboot = 1000;
end

N = size(data,1);
A_boot = zeros(nboot,1);
for i = 1:nboot
   ind = unidrnd(N,[N 1]);
   A_boot(i) = auc(data(ind,:));
end

% http://www.stat.umn.edu/geyer/old03/5601/examp/tests.html
% lower-tailed test of A = H0
ltpv = mean(A_boot <= H0);
% upper-tailed test of A = H0
utpv = mean(A_boot >= H0);
% two-tailed test of A = H0, equal-tailed two-sided intervals
ttpv = 2*min(ltpv,utpv);

if strcmp(flag,'upper')
   p = ltpv;
elseif strcmp(flag,'lower')
   p = utpv;
else
   p = ttpv;
end
