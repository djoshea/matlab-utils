function [K,varargout] = kernel(X,Y,varargin)

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'X',@isnumeric);
addRequired(par,'Y',@isnumeric);
addParamValue(par,'kernel','rbf',@ischar);
parse(par,X,Y,varargin{:});

switch lower(par.Results.kernel)
   case {'linear'}
      if isempty(Y)
         K = X*X';
      else
         K = X*Y';
      end
   case {'poly'}
      % TODO
   case {'rbf' 'gaussian' 'gauss'}
      [K,sigma] = utils.rbf(X,Y,par.Unmatched);
      if nargout > 1
         varargout{1} = sigma;
      end
   case {'brownian' 'dist' 'distance'}
      if isempty(Y)
         K = utils.distkern(X,X);
      else
         K = utils.distkern(X,Y);
      end
end