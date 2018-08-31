function data = h5readAll(file)
    info = h5info(file);
    data = readPrefix(info, '', file);
end

function t = readPrefix(info, prefix, file)
    ds = info.Datasets;
    for iD = 1:numel(ds)
        if isempty(prefix)
            name = ['/', ds(iD).Name];
        else
            name = [prefix, ds(iD).Name];
        end
        
        value = h5read(file, name);
        
        fld = matlab.lang.makeValidName(ds(iD).Name);
        t.(fld) = value;
    end

    groups = info.Groups;
    for iG = 1:numel(groups)
        t.(groups{iG}) = readPrefix(groups(iG), [prefix, groups(iG).Name, '/'], file);
    end
end