function target = resolveSymLink(file)

    if ismac
        target = file;
        return;
    else
        target = getResolved(file);
    end
    
    return;

    if ~exist(file, 'file')
        % try recursively on its parent
        [parent leaf ext] = fileparts(file);
        parent = resolveSymLink(parent);
        target = fullfile(parent, [leaf ext]);
    else
        target = getResolved(file);
    end

    return;
    
    function result = getResolved(file)
        cmd = sprintf('readlink -m %s', escapePathForShell(GetFullPath(file)));
        [status result] = system(cmd);
        if status || isempty(result);
            fprintf(result);
            error('Error resolving sym link');
        end 
        
        NEWLINE = 10;
        if result(end) == NEWLINE
            result = result(1:end-1);
        end
    end
end

