% NYSTROM                     Nystrom approximation of kernel matrix
% 
%     [phi,K] = nystrom(X,varargin)
% 
%     INPUTS
%     X     - [n x p] n samples of dimensionality p
% 
%     OPTIONAL
%     c    - scalar, number of columns to sample (without replacement)
%     rsvd - boolean indicating whether to use randomized SVD
%     tol  - scalar tolerance for truncating small singular values
% 
%     Additional name/value pairs are passed through to RSVD if true.
% 
%     OUTPUTS
%     phi   - approximate feature mapped data
%     K     - approximate Gram matrix
%
%     REFERENCES
%     Wang (2015). A Practical Guide to Randomized Matrix Computations with 
%       MATLAB Implementations. https://arxiv.org/abs/1505.07570
%
%     SEE ALSO
%     rsvd

function [phi,K] = nystrom(X,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'X',@isnumeric);
addParamValue(par,'c',[],@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'rsvd',false,@islogical);
addParamValue(par,'tol',[],@(x) isnumeric(x) && isscalar(x));
parse(par,X,varargin{:});

[n,p] = size(X);
if isempty(par.Results.c)
   c = fix(0.25*n); % Default to 25% columns
else
   c = min(par.Results.c,n);
end

ind = randperm(n);
ind = ind(1:c);
C = utils.kernel(X,X(ind,:),par.Unmatched); % C = K(:,ind)
W = C(ind,:);

if par.Results.rsvd
   %[U,S] = utils.rsvd(W,par.Unmatched);
   [U,S] = utils.rsvd(W,30,10,3);
else
   [U,S] = svd(W);
end
s = diag(S);
if isempty(par.Results.tol)
   tol = max(size(W)) * eps(norm(s,inf)); % from pinv
else
   tol = par.Results.tol;
end
c = sum(s > tol);
s = 1./sqrt(s(1:c));
UW = bsxfun(@times,U(:,1:c),s');

phi = C*UW;

if nargout == 2
   K = phi*phi';
end