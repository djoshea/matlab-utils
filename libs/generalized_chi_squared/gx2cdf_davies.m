function [p,flag]=gx2cdf_davies(x,lambda,m,delta,sigma,c,varargin)
% Returns the CDF of a generalized chi-squared (a weighted sum of
% non-central chi-squares and a normal), using Davies' [1973] method.

% Syntax:
% p=gx2cdf_davies(x,lambda,m,delta,sigma,c)
% p=gx2cdf_davies(x,lambda,m,delta,sigma,c,'upper')
% p=gx2cdf_davies(x,lambda,m,delta,sigma,c,'AbsTol',0,'RelTol',1e-7)

% Example:
% p=gx2cdf_davies(25,[1 -5 2],[1 2 3],[2 3 7],5,0)

% Inputs:
% x         point at which to evaluate the CDF
% lambda    row vector of coefficients of the non-central chi-squares
% m         row vector of degrees of freedom of the non-central chi-squares
% delta     row vector of non-centrality paramaters (sum of squares of
%           means) of the non-central chi-squares
% sigma     scale of normal term
% c         constant term
% 'upper'   more accurate estimate of the complementary CDF when it's small
% 'AbsTol'  absolute error tolerance for the output
% 'RelTol'  relative error tolerance for the output
%           The absolute OR the relative tolerance is satisfied.

% Output:
% p         computed CDF
% flag      =1 if output was too close to 0 or 1 to compute exactly with
%           default settings. Try stricter tolerances.

% Author:
% Abhranil Das <abhranil.das@utexas.edu>
% Center for Perceptual Systems, University of Texas at Austin

% If you use this code, you may cite:
% A new method to compute classification error
% jov.arvojournals.org/article.aspx?articleid=2750251

parser = inputParser;
addRequired(parser,'x',@(x) isreal(x) && isscalar(x));
addRequired(parser,'lambda',@(x) isreal(x) && isrow(x));
addRequired(parser,'m',@(x) isreal(x) && isrow(x));
addRequired(parser,'delta',@(x) isreal(x) && isrow(x));
addRequired(parser,'sigma',@(x) isreal(x) && isscalar(x));
addRequired(parser,'c',@(x) isreal(x) && isscalar(x));
addOptional(parser,'side','lower',@(x) strcmpi(x,'lower') || strcmpi(x,'upper') );
addParameter(parser,'AbsTol',1e-10,@(x) isreal(x) && isscalar(x) && (x>=0));
addParameter(parser,'RelTol',1e-6,@(x) isreal(x) && isscalar(x) && (x>=0));

parse(parser,x,lambda,m,delta,sigma,c,varargin{:});
side=parser.Results.side;
flag=false;
u=[]; % pre-allocate in static workspace

% define the integrand (lambda, m, delta must be column vectors here)
    function f=davies_integrand(u,x,lambda,m,delta,sigma)
        theta=sum(m.*atan(lambda*u)+(delta.*(lambda*u))./(1+lambda.^2*u.^2),1)/2-u*x/2;
        rho=prod(((1+lambda.^2*u.^2).^(m/4)).*exp(((lambda.^2*u.^2).*delta)./(2*(1+lambda.^2*u.^2))+u.^2*sigma^2/8),1);
        f=sin(theta)./(u.*rho);
    end

% compute the integral
if any(strcmp(parser.UsingDefaults,'AbsTol')) && any(strcmp(parser.UsingDefaults,'RelTol'))
    davies_integral=integral(@(u) davies_integrand(u,x-c,lambda',m',delta',sigma),0,inf);
    if strcmpi(side,'lower')
        p=0.5-davies_integral/pi;
    elseif strcmpi(side,'upper')
        p=0.5+davies_integral/pi;
    end
else
    syms u
    davies_integral=vpaintegral(@(u) davies_integrand(u,x-c,lambda',m',delta',sigma),u,0,inf,'AbsTol',parser.Results.AbsTol,'RelTol',parser.Results.RelTol,'MaxFunctionCalls',inf);
    if strcmpi(side,'lower')
        p=double(0.5-davies_integral/pi);
    elseif strcmpi(side,'upper')
        p=double(0.5+davies_integral/pi);
    end
end

if p<0
    p=0;
    flag=true;
elseif p>1
    p=1;
    flag=true;
end

end