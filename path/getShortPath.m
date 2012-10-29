function fnamesShort = getShortPath(fnamesLong)

if ischar(fnamesLong)
    fnamesShort = shortPathFn(fnamesLong);
else
    fnamesShort = cellfun(@shortPathFn, fnamesLong, 'UniformOutput', false);
end

end

function str = shortPathFn(fname)
    [~, name ext] = fileparts(fname);
    str = [name ext];
end
