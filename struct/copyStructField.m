function Sdest = copyStructField(Ssrc, Sdest, fromFields, toFields)
% Sdest = copyStructField(Ssrc, Sdest, fromFields, toFields)
% copies each Ssrc(i).(fromFields{j}) to Sdest(i).(toFields{j})
%
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