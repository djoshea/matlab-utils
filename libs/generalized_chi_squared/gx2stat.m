function [mu,v]=gx2stat(lambda,m,delta,sigma,c)
% Returns the mean and variance of a generalized chi-squared variable
% (a weighted sum of non-central chi-squares).

% Example:
% [mu,v]=gx2stat([1 -5 2],[1 2 3],[2 3 7],4,0)

% Inputs:
% lambda    row vector of coefficients of the non-central chi-squares
% m         row vector of degrees of freedom of the non-central chi-squares
% delta     row vector of non-centrality paramaters (sum of squares of
%           means) of the non-central chi-squares
% sigma     scale of normal term
% c         constant term

% Outputs:
% mu        mean
% v         variance

% Author:
% Abhranil Das <abhranil.das@utexas.edu>
% Center for Perceptual Systems, University of Texas at Austin

% If you use this code, you may cite:
% A new method to compute classification error
% jov.arvojournals.org/article.aspx?articleid=2750251

parser = inputParser;
addRequired(parser,'lambda',@(x) isreal(x) && isrow(x));
addRequired(parser,'m',@(x) isreal(x) && isrow(x));
addRequired(parser,'delta',@(x) isreal(x) && isrow(x));
addRequired(parser,'c',@(x) isreal(x) && isscalar(x));
parse(parser,lambda,m,delta,c);

mu=dot(lambda,m+delta)+c;
v=2*dot(lambda.^2,m+2*delta)+sigma^2;