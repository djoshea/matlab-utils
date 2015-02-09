function printStructBytesByFieldName(S)

    flds = fieldnames(S);

    bytes = nanvec(numel(flds));
    for iF = 1:numel(flds)
        fld = flds{iF};
        vals = {S.(fld)};

        d = whos('vals');
        bytes(iF) = d.bytes;
    end

    [bytes, idxSort] = sort(bytes, 1, 'descend');
    flds = flds(idxSort);
    
    maxFldLen = max(cellfun(@numel, flds));
    
    for iF = 1:numel(flds)
        fprintf('%*s\t%12d\n', maxFldLen, flds{iF}, bytes(iF));
    end

end