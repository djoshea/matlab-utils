function R = selectalongfirstdimension(IN, f)

% R = selectalongfirstdimension(IN,f)
%
% equivalent of IN(f) for 1D, IN(f,:) for 2D, IN(f,:,:) for 3D, etc...
%
% INPUTS:
%    IN = any matrix input
%    f = selection indices (such as returned by find)
%
% OUTPUTS:
%    R = same type matrix as IN 
%
%
% ADR 1998
% version L5.0
% v 5.0 now can handle NaN indices
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

sz = size(IN);
dim1 = sz(1);
dimRest = sz(2:length(sz));

tmpMatrix = reshape(IN, [dim1 prod(dimRest)]);

yesnan = isnan(f);
if any(yesnan)
    f1 = f;
    f1(yesnan) = 1;
    tmpMatrix = tmpMatrix(f1,:);
    tmpMatrix(yesnan,:) = NaN;
else
    tmpMatrix = tmpMatrix(f,:);
end

R = reshape(tmpMatrix, [length(f) dimRest]);