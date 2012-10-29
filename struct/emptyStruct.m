function S = emptyStruct(S, val)
    % S = emptyStruct(S, val=[])
    % returns S with all of its fields set to val
    
    if ~exist('val', 'var')
        val = [];
    end

    fields = fieldnames(S);
    for iF = 1:length(fields)
        for iS = 1:length(S)
            S(iS).(fields{iF}) = val;
        end
    end
end
