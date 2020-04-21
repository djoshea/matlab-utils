function local_atom(path)

if isstringlike(path)
    name = path;
    path = which(name);
    if exist(path, 'file') ~= 2
        error('Could not find %s', path);
    end
else
    % assume path is a variable
    path = which(class(path));
end

cmd = sprintf('atom %s', path);

fprintf('Executing %s\n', cmd);
system(cmd);

end