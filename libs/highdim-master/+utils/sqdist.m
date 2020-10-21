% Squared euclidean distance matrix
% Faster than pdist2(x,x) & squareform(pdist(x))
%
% x = randn(5000,1000);
% y = randn(200,1000);
% tic; sqrt(utils.sqdist(x)); toc
% tic; pdist2(x,x); toc
% norm(utils.sqdist(x) - pdist2(x,x).^2,'fro')
% norm(utils.sqdist(x,y) - pdist2(x,y).^2,'fro')
function D = sqdist(X,Y)

if (nargin == 1) || isempty(Y)
   XX = sum(X.*X,2);
   D = bsxfun(@plus,XX,XX') - 2*(X*X');
else
   [m,p] = size(X);
   [n,q] = size(Y);
   assert(p==q,'Input dimensions must match');

   Yt = Y';
   XX = sum(X.*X,2);
   YY = sum(Yt.*Yt,1);
   D = bsxfun(@plus,XX,YY) - 2*(X*Yt);
end

%D(D<0) = 0;
