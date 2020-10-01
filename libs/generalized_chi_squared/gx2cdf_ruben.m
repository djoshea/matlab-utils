function [p,err]=gx2cdf_ruben(x,lambda,m,delta,c,K)
% Returns the CDF of a generalized chi-squared (a weighted sum of
% non-central chi-squares with all weights the same sign), using Ruben's
% [1962] method.

% Syntax:
% p=gx2cdf_ruben(x,lambda,m,delta,c)
% p=gx2cdf_ruben(x,lambda,m,delta,c,K)
% [p,err]=gx2cdf_ruben(x,lambda,m,delta,c)

% Example:
% [p,err]=gx2cdf_ruben(25,[1 5 2],[1 2 3],[2 3 7],0,100)

% Inputs:
% x         point at which to evaluate the CDF
% lambda    row vector of coefficients of the non-central chi-squares
% m         row vector of degrees of freedom of the non-central chi-squares
% delta     row vector of non-centrality paramaters (sum of squares of
%           means) of the non-central chi-squares
% c         constant term
% K         no. of terms in the approximation. Default = 1000.

% Outputs:
% p         computed CDF
% err       upper error bound of the CDF estimate

% Author:
% Abhranil Das <abhranil.das@utexas.edu>
% Center for Perceptual Systems, University of Texas at Austin

% If you use this code, you may cite:
% A new method to compute classification error
% jov.arvojournals.org/article.aspx?articleid=2750251

if all(lambda>0)||all(lambda<0) % check that coefficients are the same sign.    
    if ~exist('K','var')
        K=1e3;
    end
    
    beta=0.90625*min(lambda);
    M=sum(m);
    
    k=(1:K-1)';
    
    % compute the g's
    g=sum(m.*(1-beta./lambda).^k,2)+ beta*k.*((1-beta./lambda).^(k-1))*(delta./lambda)';
    
    % compute the expansion coefficients
    a=nan(K,1);
    a(1)=sqrt(exp(-sum(delta))*beta^M*prod(lambda.^(-m)));
    if a(1)<realmin
        error('Underflow error: some expansion coefficients are smaller than machine precision.')
    end
    for j=1:K-1
        a(j+1)=dot(flip(g(1:j)),a(1:j))/(2*j);
    end
    
    % compute the central chi-squared integrals
    F=chi2cdf((x-c)/beta,M:2:M+2*(K-1));
    
    % compute the integral
    p=dot(a,F);
    
    % compute the truncation error
    err=(1-sum(a))*chi2cdf((x-c)/beta,M+2*K);
else
    error('Ruben''s method cannot handle coefficients of different signs. Use Imhof''s or Davies'' method.');
end