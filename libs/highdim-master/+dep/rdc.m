% RDC                         Randomized dependence coefficient
%
%     r = rdc(x,y,varargin)
%
%     RDC is the largest canonical correlation as computed by RCCA on random 
%     features of the copula transformations of two random samples
%
%     INPUTS
%     x     - [n x p] n samples of dimensionality p
%     y     - [n x q] n samples of dimensionality q
%
%     OPTIONAL
%     k
%     s
%     f
%     demean
%
%     OUTPUTS
%
%     REFERENCE
%

% Based on R code:
% https://github.com/lopezpaz/randomized_dependence_coefficient/blob/master/code/algorithms.r
% rdc <- function(x,y,k=20,s=1/6,f=sin) {
%   x <- cbind(apply(as.matrix(x),2,function(u)rank(u)/length(u)),1)
%   y <- cbind(apply(as.matrix(y),2,function(u)rank(u)/length(u)),1)
%   x <- s/ncol(x)*x%*%matrix(rnorm(ncol(x)*k),ncol(x))
%   y <- s/ncol(y)*y%*%matrix(rnorm(ncol(y)*k),ncol(y))
%   cancor(cbind(f(x),1),cbind(f(y),1))$cor[1]
% }

function r = rdc(x,y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'x',@isnumeric);
addRequired(par,'y',@isnumeric);
addParamValue(par,'k',20,@isscalar);
addParamValue(par,'s',1/6,@isscalar);
addParamValue(par,'f',@sin,@(x) isa(x,'function_handle'));
addParamValue(par,'demean',false,@islogical);
parse(par,x,y,varargin{:});

n = size(x,1);
if par.Results.demean
   x = bsxfun(@minus,x,mean(x));
   y = bsxfun(@minus,y,mean(y));
end

x = [tiedrank(x)/n ones(n,1)];
y = [tiedrank(y)/n ones(n,1)];

f = par.Results.f;
s = par.Results.s;
k = par.Results.k;
x = f(s/size(x,2)*x*randn(size(x,2),k));
y = f(s/size(y,2)*y*randn(size(y,2),k));

warning('off','stats:canoncorr:NotFullRank');
[~,~,r] = canoncorr([x ones(n,1)],[y ones(n,1)]);
warning('on','stats:canoncorr:NotFullRank');

r = r(1);

