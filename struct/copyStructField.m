function Sdest = copyStructField(Ssrc, Sdest, fromFields, toFields)

    if nargin < 4
        toFields = fromFields;
    end
    
    if ~iscell(fromFields)
        fromFields = {fromFields};
        toFields = {toFields};
    end
     
    N = numel(Ssrc);
    if isempty(Sdest)
        Sdest = emptyStructArray(size(Ssrc));
    end
    for iA = 1:numel(fromFields)
        [Sdest(1:N).(toFields{iA})] = Ssrc.(fromFields{iA});
    end
end