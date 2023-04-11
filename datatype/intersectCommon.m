function [common, inds_c] = intersectCommon(sets_c, masks_c)
% finds the common intersection of a set of lists

if isempty(sets_c)
    common = [];
    inds_c = [];
    return
end

nS = numel(sets_c);

if nargin < 2
    for iS = 1:nS
        masks_c{iS} = true(size(sets_c{iS}));
    end
end

for iS = 1:nS
    if iS == 1
        common = unique(sets_c{iS}(masks_c{iS}));
    else
        common = intersect(common, sets_c{iS}(masks_c{iS}));
    end
end

inds_c = cell(nS, 1);
for iS = 1:nS
    [tf, this_inds] = ismember(common, sets_c{iS});
    assert(all(tf));
    inds_c{iS} = this_inds;
end

end