function sortedVals = sortUsingPartialOrdering(vals, ordering)
% Given a list of values vals and a partial ordering over those values
% return sortedVals list vals where any values in ordering appear in the
% specified order, followed by the remaining values in vals sortedVals via sort()
%
% Example: 
% vals = [1:5]; ordering = [4 3];
% sortedVals = sortUsingPartialOrdering(vals, ordering)
% sortedVals == [4 3 1 2 5];

assert(isvector(vals) && isvector(ordering), 'Only vector inputs are supported');
vals = makecol(vals);
ordering = makecol(ordering);

if iscell(vals)
    sortedVals = {};
else
    sortedVals = [];
end

usedMask = false(numel(vals),1);

if ~iscell(ordering)
    ordering = num2cell(ordering);
end

for iO = 1:length(ordering)
    valsMatch = ~usedMask & ismember(vals, ordering{iO});
    if any(valsMatch)
        % append the matching values
        sortedVals = [sortedVals; vals(valsMatch)];

        % mark them as included
        usedMask = usedMask | valsMatch;
    end
end

% now include the remaining trials
if any(~usedMask)
    remaining = sort(vals(~usedMask));
    sortedVals = [sortedVals; remaining];
end

sortedVals = makecol(sortedVals);

end
