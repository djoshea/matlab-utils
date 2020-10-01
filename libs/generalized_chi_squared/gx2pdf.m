function f=gx2pdf(x,lambda,m,delta,sigma,c,varargin)
% Returns the PDF of a generalized chi-squared (a weighted sum of
% non-central chi-squares), by differentiating the CDF computed using
% Davies' [1973] method.

% Syntax:
% f=gx2pdf(x,lambda,m,delta,sigma,c)
% f=gx2pdf(x,lambda,m,delta,sigma,c,'dx',1e-1)
% f=gx2pdf(x,lambda,m,delta,sigma,c,'AbsTol',0,'RelTol',1e-7)

% Example:
% f=gx2pdf(25,[1 -5 2],[1 2 3],[2 3 7],5,0)

% Inputs:
% x         point at which to evaluate the PDF
% lambda    row vector of coefficients of the non-central chi-squares
% m         row vector of degrees of freedom of the non-central chi-squares
% delta     row vector of non-centrality paramaters (sum of squares of
%           means) of the non-central chi-squares
% sigma     scale of normal term
% c         constant term
% dx        fineness for numerically differentiating the CDF to compute PDF
% 'AbsTol'  absolute error tolerance for the CDF computation
% 'RelTol'  relative error tolerance for the CDF computation
%           The absolute OR the relative tolerance is satisfied.

% Output:
% f         computed PDF

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
addParameter(parser,'dx',1e-10,@(x) isreal(x) && isscalar(x) && (x>=0));
addParameter(parser,'AbsTol',1e-10,@(x) isreal(x) && isscalar(x) && (x>=0));
addParameter(parser,'RelTol',1e-6,@(x) isreal(x) && isscalar(x) && (x>=0));

parse(parser,x,lambda,m,delta,sigma,c,varargin{:});

dx=parser.Results.dx;
if any(strcmp(varargin,'dx'))
    removeIndex=strcmp(varargin(:,1),'dx');
    varargin(removeIndex,:)=[];
end

p_right=gx2cdf_davies(x+dx,lambda,m,delta,sigma,c,varargin{:});
p_left=gx2cdf_davies(x-dx,lambda,m,delta,sigma,c,varargin{:});

f=(p_right-p_left)/(2*dx);

end