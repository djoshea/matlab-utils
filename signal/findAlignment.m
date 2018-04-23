function [offset, maxDelta] = findAlignment(reference, insert, refFirstValid, refLastValid, minOverlap, refValid, ignoreValue)

    if nargin < 5
        minOverlap = 10;
    end
    if nargin < 3 || isempty(refFirstValid) || refFirstValid == 1
        % if not specified, allow negative offsets
        % if we want min overlap of 1, then if numel(insert) is say 3, we
        % can start with offset == -2 (meaning reference(1) == insert(3))
        minOffset = 1 - numel(insert) + (minOverlap-1);
    else
        minOffset = refFirstValid - 1;
    end
    
    if nargin < 4
        % if say numel(reference) is 10 and minOverlap is 1, then max offset is
        % 9 meaning insert(1) --> reference(10)
        maxOffset = numel(reference) - minOverlap;
    else
        maxOffset = refLastValid - minOverlap;
    end

    if nargin < 5 || isempty(refValid)
        refValid = true(size(reference));
    end
    if nargin < 6 || isempty(ignoreValue)
        ignoreValue = inf;
    end

    nIns = numel(insert);
    nRef = numel(reference);
    
    

    offsetsPossible = minOffset:maxOffset;
    nOffsets = numel(offsetsPossible);
    maxDeltaByOffset = nan(nOffsets, 1);
    
    for io = 1:nOffsets
        offset = offsetsPossible(io);
        indRef = (1:nIns) + offset;
        indIns = 1:nIns;
        maskWithin = indRef >=1 & indRef <= nRef;
        indRef = indRef(maskWithin);
        indIns = indIns(maskWithin);
        refPiece = reference(indRef);
        insPiece = insert(indIns);
        mask = refValid(indRef) & ~(refPiece == ignoreValue | insPiece == ignoreValue);

        if any(mask)
            maxDeltaByOffset(io) = nanmax(abs(insPiece(mask) - refPiece(mask)));
        end
    end

    [maxDelta, idx] = nanmin(maxDeltaByOffset);
    offset = offsetsPossible(idx);
    
    return;
    
    %%
    figure(1); clf;
    plot(offsetsPossible, maxDeltaByOffset, 'k-');
    hold on;
    plot(offset, maxDelta, 'rx');
    
    % plot for verification
    figure(2); clf;
    plot(1:nRef, reference, 'r-');
    hold on;
    plot((1:nIns) + offset, insert, 'b-');
    
    %% interactive
    figure(3); clf;
    plot(reference, 'r-');
    hu = gca;
    xlim(hu, [0 100]);
    ylim(hu, [-100 900]);
    hl = axes('OuterPosition', [0 0 1 0.7], 'Color', 'none');
    plot(insert, 'b-');
    hl.Color = 'none';
    xlim(hl, [0 100]);
    ylim(hl, [-100 900]);
    
    
end

