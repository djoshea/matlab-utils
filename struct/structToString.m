function str = structToString(s)
% given a struct s with string or numeric vector values, convert to string

    fields = fieldnames(s);
    if isempty(fields)
        str = '';
        return;
    end
    vals = structfun(@convertToString, s);

    str = strjoin(cellfun(@(fld, val) [fld '=' val], fields, vals, 'UniformOutput', false), ' ');
    
    return;
    
    function str = convertToString(v)
        if ischar(v)
            str = v;
        elseif isempty(v)
            str = '[]';
        elseif isnumeric(v) || islogical(v)
            str = mat2str(v);
        elseif iscellstr(v)
            str = ['{', strjoin(v, ','), '}'];
        else
            error('Could not convert struct field value');
        end
        
        str = {str};
    end        

end