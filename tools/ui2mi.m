function maskedIdx = ui2mi(unmaskedIdx, mask)
% maskedIdx = ui2mi(unmaskedIdx, mask)
% unmasked idx to masked idx 
% let mask be a logical mask and list = find(mask).
% then list(maskedIdx) == unmaskedIdx. Essentially finds how many 1s into
% mask that mask(unmaskedIdx) is.

list = find(mask);
maskedIdx = arrayfun(@(u) find(list == u), unmaskedIdx, 'ErrorHandler', @(varargin) NaN);

