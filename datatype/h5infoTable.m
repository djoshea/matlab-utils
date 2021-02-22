function t = h5infoTable(file, rowMajor)
    if nargin < 2
        rowMajor = false;
    end
    info = h5info(file);

    ds = info.Datasets;

    [name, size, type] = deal(cell(numel(ds), 1));
    for iD = 1:numel(ds)
        name{iD} = ds(iD).Name;
        if rowMajor
            % python is row major but Matlab is column major
            size{iD} = vec2str(fliplr(ds(iD).Dataspace.Size));
        else
            size{iD} = vec2str(ds(iD).Dataspace.Size);
        end
        type{iD} = display_datatype_by_class(ds(iD).Datatype);
    end

    name = string(name);
    size = string(size);
    type = string(type);
    t = table(name, size, type);
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
