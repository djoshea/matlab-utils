function unmaskedIdx = mi2ui(maskedIdx, mask)
% unmaskedIdx = mi2ui(maskedIdx, mask)
% convert masked idx to unmasked idx
% let mask be a logical mask and list = find(mask).
% then list(maskedIdx) == unmaskedIdx. Essentially finds the location of
% the maskedIdx'th 1 in mask.

list = find(mask);
unmaskedIdx = list(maskedIdx);
