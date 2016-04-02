function delays = finddelayMatrix(x,varargin)
%FINDDELAYMATRIX Estimates delays between sets of simultaneously sampled signals.
%   [delays, aligned] = FINDDELAY(X)
%
%   X is a 3 dimensional tensor
%   Dim 1 is time, Dim 2 is over channels, Dim 3 is over repetitions
%   size is T x C x R
%   delays is R x 1 set of delays used to slide each T x C matrix to align
%
%   parameters:
%     alignTo: T x C matrix to align each trace to. By default is
%       nanmean(x, 3)
%     
%     fillMode: how to fill the edges of the matrix can be a scalar 
%
%   based off Matlab's finddelay

% fft function in xcorr only works on double and single data types.
assert(ndims(x) <= 3);

T = size(x, 1);
C = size(x, 2);
R = size(x, 3);

p = inputParser();
p.addOptional('maxLag', size(x, 1) / 2, @isscalar);
p.addParameter('alignTo', nanmean(x, 3), @isnumeric);
p.addParameter('fillMode', NaN, @(x) true);
p.parse(varargin{:});

y = p.Results.alignTo;
maxLag = p.Results.maxLag;
 
% The largest maximum window size determines the size of the 
% cross-correlation vector/matrix c.
% Preallocate normalized cross-correlation vector/matrix c.
c_normalized = zeros(2*maxLag+1,C,R);
lags = -maxLag:maxLag;
nLags = size(c_normalized, 1);
index_max = zeros(1,1,R);

% Compute absolute values of normalized cross-correlations between x and
% all columns of y: function XCORR does not take into account special case
% when either x or y is all zeros, so we don't use its normalization option
% 'coeff'. Values of normalized cross-correlations computed for a lag of
% zero are stored in the middle row of c at index i = max_maxlag+1 (c has
% an odd number of rows).
cxx0 = sum(abs(x).^2, 1); % 1 x C x R
cyy0 = sum(abs(y).^2, 1); % 1 x C
for r = 1:R
    for c = 1:C
        if ( (cxx0(1, c, r)==0) || (cyy0(1, c)==0) )
            % If either channel is zero, set c to all zeros.
            c_normalized(:,c,r) = 0;
        else
            % Otherwise calculate c_normalized.
            c_normalized(:,c,r) = abs(xcorr(x(:,c,r),y(:,c), maxLag))/sqrt(cxx0(1, c, r)*cyy0(1, c));
        end
    end
end

% sum the cross correlations across channels
c_normalized_sum = TensorUtils.squeezeDims(sum(c_normalized, 2), 2); % nLags x R;

% Find indices of lags resulting in the largest absolute values of
% normalized cross-correlations: to deal with periodic signals, seek the
% lowest (in absolute value) lag giving the largest absolute value of
% normalized cross-correlation.
% Find lowest positive or zero indices of lags (negative delays) giving the
% largest absolute values of normalized cross-correlations. 
[max_c_pos,index_max_pos] = max(c_normalized_sum(maxLag+1:end,:),[],1);    
% Find lowest negative indices of lags (positive delays) giving the largest
% absolute values of normalized cross-correlations. 
[max_c_neg,index_max_neg] = max(flipud(c_normalized_sum(1:maxLag,:)),[],1);

max_c = nan(R, 1);

if isempty(max_c_neg)
    % Case where MAXLAG is all zeros.
    index_max = maxLag + index_max_pos;
else
    for r=1:R
        if max_c_pos(r)>max_c_neg(r)
            % The estimated lag is positive or zero.
            index_max(r) = maxLag + index_max_pos(r);
            max_c(r) = max_c_pos(r);
        elseif max_c_pos(r)<max_c_neg(r)
            % The estimated lag is negative.
            index_max(r) = maxLag + 1 - index_max_neg(r);
            max_c(r) = max_c_neg(r);
        elseif max_c_pos(r)==max_c_neg(r)
            if index_max_pos(r)<=index_max_neg(r)
                % The estimated lag is positive or zero.
                index_max(r) = max_maxlag + index_max_pos(r);
                max_c(r) = max_c_pos(r);
            else
                % The estimated lag is negative.
                index_max(r) = max_maxlag + 1 - index_max_neg(r);
                max_c(r) = max_c_neg(r);
            end 
        end   
    end
end

% Subtract delays.
delays = lags(index_max);

% Set to zeros estimated delays for which the normalized cross-correlation
% values are below a given threshold (spurious peaks due to FFT roundoff
% errors).
for i=1:R
    if max_c(r)<1e-8
        delays(r) =  0;
        if isscalar(d) && maxlag(r)~=0
            warning(message('signal:finddelay:noSignificantCorrelationScalar'));
        elseif isvector(d) && maxlag(r)~=0
            warning(message('signal:finddelay:noSignificantCorrelationVector', r));
        end
    end    
end

% EOF

