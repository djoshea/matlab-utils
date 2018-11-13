function str = structToString(s, separator)
% given a struct s with string or numeric vector values, convert to string
    if nargin < 2
        separator = ' ';
    end

    fields = fieldnames(s);
    if isempty(fields)
        str = '';
        return;
    end
    vals = structfun(@convertToString, s);

    str = strjoin(cellfun(@(fld, val) [fld '=' val], fields, vals, 'UniformOutput', false), separator);
    
    return;
    
    function str = convertToString(v)
        if ischar(v)
            str = v;
        elseif isempty(v)
            str = '[]';
        elseif isnumeric(v) || islogical(v)
            str = mat2str(v);
        elseif iscategorical(v)
            str = ['{', strjoin(arrayfun(@char, v, 'UniformOutput', false), ','), '}'];
        elseif iscellstr(v)
            str = ['{', strjoin(v, ','), '}'];
        elseif isobject(v)
            if ismethod(v, 'char')
                str = char(v);
            elseif ismethod(v, 'describe')
                str = describe(v);
            else
                str = class(v);
            end
        else
            error('Could not convert struct field value');
        end
        
        str = {str};
    end        

end