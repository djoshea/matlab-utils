function y = movquantile(x, p, span, varargin)
% x is a matrix nTime x nObs
% we want to compute the moving qth quantile
% y is nTime x nObs x nP set of quantiles
% at present, assumes dim 1 the dimension we take the quantile over
% unlike quantile, dim 1 will remain time, and the individual quantiles will be placed along the last dimension

parser = inputParser();
parser.addParameter('showProgress', false, @islogical);
parser.parse(varargin{:});
showProgress = parser.Results.showProgress;

sWarn = warning('off', 'MATLAB:toeplitz:DiagonalConflict');

[T, N] = size(x(:, :));

assert(all(mod(span, 1) == 0), 'Span must be integer');

if isscalar(span)
    if mod(span, 2) == 0
        % even
        half = span/2;
        span = [half half-1];
    else
        % odd
        half = (span-1)/2;
        span = [half half];
    end
end
pre = span(1);
post = span(2);

assert(pre >= 0 & post >= 0);
K = pre + post + 1;
P = numel(p);

% we use quantile to do the heavy lifting, but first construct a sliding window of time using toeplitz
y = nan(T, N, P, 'like', x);

if showProgress
    prog = ProgressBar(N, 'Computing moving quantiles');
end

for c = 1:N
%     vec = [repmat(x(1, c), pre, 1); x(:, c); repmat(x(end, c), post, 1)];
    vec = [x(:, c); nan(post, 1)];
    
    toep = toeplitz(vec, nan(K, 1)); % T x K
    qu = quantile(toep, p, 2); % P x K
    
    y(:, c, :) = reshape(qu(post+1:end, :), [T 1 P]);
    if showProgress, prog.update(c); end
end
if showProgress, prog.finish(); end

warning(sWarn);

end