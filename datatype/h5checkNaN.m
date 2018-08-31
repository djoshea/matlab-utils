function t = h5checkNaN(file)
    info = h5info(file);
    t = checkNaN(info, '', file);
end

function t = checkNaN(info, prefix, file)
    ds = info.Datasets;
    [name, size, type] = deal(cell(numel(ds), 1));
    hasNaN = nan(numel(ds), 1);
    for iD = 1:numel(ds)
        if isempty(prefix)
            name{iD} = ['/', ds(iD).Name];
        else
            name{iD} = [prefix, ds(iD).Name];
        end
        size{iD} = vec2str(ds(iD).Dataspace.Size);
        type{iD} = display_datatype_by_class(ds(iD).Datatype);
        
        value = h5read(file, name{iD});
        if isnumeric(value)
            hasNaN(iD) = any(isnan(value(:)));
        end
    end

    t = table(name, size, type, hasNaN);
    
    groups = info.Groups;
    for iG = 1:numel(groups)
        t = cat(1, t, buildTable(groups(iG), [prefix, groups(iG).Name, '/']));
    end
end

%% these are stolen from h5disp.m

function str = display_datatype_by_class(datatype)

switch(datatype.Class)
    case 'H5T_INTEGER'
        str = display_integer_datatype(datatype);
        
    case 'H5T_FLOAT'
        str = display_floating_point_datatype(datatype);
        
    otherwise
        str = datatype.Class;
        
end

end

%--------------------------------------------------------------------------
function str = display_integer_datatype(datatype)
%
% This function displays something like the following:
%
%         Datatype:   H5T_STD_I32BE (int32)


switch(datatype.Type)
    case { 'H5T_STD_U64LE', 'H5T_STD_U64BE', ...
            'H5T_STD_U32LE', 'H5T_STD_U32BE', ...
            'H5T_STD_U16LE', 'H5T_STD_U16BE', ...
            'H5T_STD_U8LE', 'H5T_STD_U8BE' }
        uint_desc = getString(message('MATLAB:imagesci:h5disp:uint',datatype.Size*8));
        str = sprintf('%s (%s)', datatype.Type, uint_desc);
        
    case { 'H5T_STD_I64LE', 'H5T_STD_I64BE', ...
            'H5T_STD_I32LE', 'H5T_STD_I32BE', ...
            'H5T_STD_I16LE', 'H5T_STD_I16BE', ...
            'H5T_STD_I8LE', 'H5T_STD_I8BE' }
        int_desc = getString(message('MATLAB:imagesci:h5disp:int',datatype.Size*8));
        str = sprintf('%s (%s)', datatype.Type, int_desc);
        
    otherwise
        str = printf('%s', datatype.Type);
        
end

end

%--------------------------------------------------------------------------
function str = display_floating_point_datatype(datatype)
%
% This function displays something like the following:
%
%     Datatype:   H5T_IEEE_F64LE (double)


switch(datatype.Type)
    case { 'H5T_IEEE_F32BE', 'H5T_IEEE_F32LE' }
        desc = getString(message('MATLAB:imagesci:h5disp:single'));
        str = sprintf('%s (%s)', datatype.Type, desc);
        
    case { 'H5T_IEEE_F64BE', 'H5T_IEEE_F64LE' }
        desc = getString(message('MATLAB:imagesci:h5disp:double'));
        str = sprintf('%s (%s)', datatype.Type, desc);
        
    otherwise
        str = sprintf('%s', datatype.Type);
end
end
