function success = makeSymLink(src, link)
% makeSymLink(src, linkDest)

    src = resolveSymLink(GetFullPath(src));
    link = GetFullPath(link);
    mkdirRecursive(fileparts(link));
    cmd = sprintf('ln -s "%s" "%s"', src, link);
    [status, output] = unix(cmd);
    
    if status
        fprintf('Error creating symlink: \n');
        fprintf('%s\n', output);
    end

    success = ~status;
end
