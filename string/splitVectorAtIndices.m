function tokens = splitVectorAtIndices(vec, idx, delimSize)
% tokens = splitVectorAtIndices(vec, idx, delimSize=1)
% splits a vector into N pieces where length(idx) == N-1
% by taking: 
% tokens{1} = vec(1:idx(1)-1), 
% tokens{2} = vec(idx(1)+delimSize:idx(2)-1); 
% ...
% tokens{numel(idx)+1} = vec(idx(1)+delimSize:end);
%
% Effectively, the values at vec(idx) will be removed and used
% to split the vector into tokens

if nargin < 3
    delimSize = 3;
end

nDelim = numel(idx);
tokenSizes = [idx(1)-1, diff(idx)-delimSize, numel(vec)-idx(end)-delimSize+1];
nTokens = numel(tokenSizes);

splitSizes = nanvec(nTokens + nDelim);
splitSizes(1:2:end) = tokenSizes;
splitSizes(2:2:end) = delimSize;

tokens = mat2cell(vec, 1, splitSizes);
tokens = tokens(1:2:end)';

end