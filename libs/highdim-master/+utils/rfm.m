% RFM                         Random feature maps for Gaussian kernel
%
%     [phi,W,rngState] = rfm(X,varargin)
%
%     INPUTS
%     X     - [n x d] n samples of dimensionality d
%
%     OPTIONAL
%     sigma    - scalar, standard deviation of Gaussian kernel, default = 1
%     sampling - string indicating method for sampling random features
%                'uniform' - Classic random fourier features (DEFAULT)
%                'qmc' - Quasi-Monte Carlo using Halton sequence
%                'orf' - Orthogonal Random Features
%                'sorf'- Structured Orthogonal Random Features
%                'mm'  - Moment-Matched
%     D        - scalar, target dimensionality of feature map
%     W        - [D x d] pre-computed feature map, convenience for a
%                applying feature map to new data
%     complex  - boolean, true returns map as complex
%     sincos   - boolean, true returns sin/cos embedding, default = true
%     The following parameters are specific for sampling = 'qmc'
%     skip     - scalar, # initial points to omit, default = 1000
%     leap     - scalar, # points in between sets, detault = 700
%     scramble - boolean, scramble sequence, default = true
%     state    - scalar, state of qmc generator
%
%     OUTPUTS
%     phi - feature mapped data
%           [n x D] when 'complex' = true
%           [n x 2D] when 'complex' = false, cos and sin components stacked
%     W   - [D x d] feature map
%     rngState - state of the RNG before sampling
%
%     REFERENCES
%     Felix et al (2016). Orthogonal random features. Advances in Neural 
%       Information Processing Systems, 1975-1983
%     Rahimi & Recht (2007). Random features for large-scale kernel machines.
%       Proc 20th Int Conf on Neural Information Processing Systems, 1177-1184
%     Shen et al (2017). Random features for shift-invariant kernels with 
%       moment matching. Proc 31st AAAI Conf on AI, 2520-2526
%     Sutherland & Schneider (2015). On the error of random fourier features.
%       UAI'15 Proc 31st Conf on Uncertainty in AI, 862-871
%     Yang et al (2014). Quasi-Monte Carlo feature maps for shift-invariant 
%       kernels. Proc 31st Int Conf on Machine Learning (ICML-14), 485-493

%     $ Copyright (C) 2017 Brian Lau, brian.lau@upmc.fr $
%     The full license and most recent version of the code can be found at:
%     https://github.com/brian-lau/highdim
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.

% TODO
% o ORF, SORF should probably be run in blocks
%   currently generates W that is dxd and extracts Dxd segment
% o fastfood
% o better default D

function [phi,W,rngState] = rfm(X,varargin)
persistent pstream; % for qmc

par = inputParser;
par.KeepUnmatched = true;
addRequired(par,'X',@isnumeric);
addParamValue(par,'sigma',[],@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'sampling','uniform',@ischar);
addParamValue(par,'W',[],@ismatrix);
addParamValue(par,'D',2^4,@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'complex',false,@islogical);
addParamValue(par,'sincos',true,@islogical);
addParamValue(par,'skip',1000,@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'leap',700,@(x) isnumeric(x) && isscalar(x));
addParamValue(par,'scramble',true,@(x) isnumeric(x) || islogical(x));
addParamValue(par,'state',[],@(x) isnumeric(x) && isscalar(x));
parse(par,X,varargin{:});

[n,d] = size(X);    % # of dimensions
D = par.Results.D;  % # of random bases
if isempty(par.Results.sigma)
   sigma = utils.sigest(X,par.Unmatched);
else
   sigma = par.Results.sigma;
end

if nargout == 3
   rngState = rng; 
end

if ~isempty(par.Results.W)
   assert(size(par.Results.W,2)==d,'Feature map dimensionality must match input data');
   W = p.Results.W;
else
   switch lower(par.Results.sampling)
      case {'uniform' 'uni' 'mc' 'rff'}
         % Random fourier features
         W = randn(D,d)/sigma;
      case {'mm'}
         if D < d
            warning('Risk of poor approximation for D << d');
         end
         G = randn(D,d);
         W = utils.whiten(G)/sigma;
      case {'qmc'}
         if isempty(pstream) ...
                || ~isa(pstream,'qrandstream') ...
                || (pstream.PointSet.size(2) ~= d)
            pset = haltonset(d,'Skip',par.Results.skip,...
               'Leap',par.Results.leap);
            if par.Results.scramble
               pset = scramble(pset,'RR2');
            end
            % Persistent stream to properly increment draws on subsequent calls
            pstream = qrandstream(pset);
            %fprintf('Halton random stream opened\n')
         end
         
         if ~isempty(par.Results.state)
            pstream.State = par.Results.state;
         end
         %fprintf('Stream state: %g\n',pstream.State);
         omega = pstream.qrand(D);
         W = norminv(omega,0,1)/sigma;
      case {'orf'}
         G = randn(max(d,D),max(d,D));
         [Q,~] = qr(G);
         
         % Chi-distributed with max(d,D) degrees of freedom
         s = sqrt(chi2rnd(max(d,D),max(d,D),1));
         % S ensures that the row norms of SQ & G are identically distributed
         S = diag(s);
         
         W = (S*Q)/sigma;
         W = W(1:D,1:d);
      case {'sorf'}
         n2 = nextpow2(max(D,d));
         % Brute-force matrix multiplication, O(d^2)
         % H = (1/sqrt(2^n2))*hadamard(2^n2);
         % D1 = diag(2*(rand(2^n2,1)<0.5) - 1);
         % D2 = diag(2*(rand(2^n2,1)<0.5) - 1);
         % D3 = diag(2*(rand(2^n2,1)<0.5) - 1);
         % W = sqrt(2^n2)*H*D1*H*D2*H*D3;

         % Using Fast Hadamard transform, O(d log d)
         Ds = 2*(rand(2^n2,3)<0.5) - 1; % Rademacher distributed diagonals
         HD1 = sqrt(2^n2)*utils.fwht( diag(Ds(:,1)) );
         HD2 = sqrt(2^n2)*utils.fwht( diag(Ds(:,2)) );
         HD3 = sqrt(2^n2)*utils.fwht( diag(Ds(:,3)) );
         
         W = sqrt(2^n2)*HD1*HD2*HD3;
         W = W(1:D,1:d)/sigma;
      case {'sc'}
         %Signed Circulant Matrix Projection
         % http://felixyu.org/pdf/cbe_slides.pdf
      otherwise
         error('Unrecognized sampling method');
   end
end

Z = X*W'; % [n x d] * [D x d]'

if par.Results.sincos
   % Use the version with sin & cos features, which is more accurate,
   % Sutherland & Schneider (2105)
   if par.Results.complex
      phi = (cos(Z) - 1i*sin(Z)) * sqrt(1/D);
   else
      phi = [cos(Z) , sin(Z)] * sqrt(1/D);
   end
else
   b = rand(1,D)*2*pi;
   phi = cos(bsxfun(@plus,Z,b)) * sqrt(1/D);
end
