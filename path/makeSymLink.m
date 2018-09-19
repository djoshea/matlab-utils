function success = makeSymLink(src, link)
% makeSymLink(src, linkDest)

    src = resolveSymLink(GetFullPath(src));
    if ~exist(src, 'file')
        warning('Source is a dangling symlink, not creating');
    end
    
    link = GetFullPath(link);
    mkdirRecursive(fileparts(link));
    if exist(link, 'file')
        delete(link);
    end
    cmd = sprintf('ln -s "%s" "%s"', src, link);
    [status, output] = unix(cmd);
    
    if status
        fprintf('Error creating symlink: \n');
        fprintf('%s\n', output);
    end

    success = ~status;
end
