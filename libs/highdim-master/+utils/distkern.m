% Sejdinovic et al, pg. 2272, example 15
% Brownian distance kernel
function k = distkern(X,Y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'X',@isnumeric);
addRequired(par,'Y',@isnumeric);
addParamValue(par,'index',1,@(x) isscalar(x) && (x>0) && (x<=2));
parse(par,X,Y,varargin{:});

Yt = Y';
XX = sqrt(sum(X.*X,2));
YY = sqrt(sum(Yt.*Yt));
D = sqrt(utils.sqdist(X,Y));

if par.Results.index ~= 1
   XX = XX.^par.Results.index;
   YY = YY.^par.Results.index;
   D = D.^par.Results.index;
end

k = 0.5 * (bsxfun(@plus,XX,YY) - D);
