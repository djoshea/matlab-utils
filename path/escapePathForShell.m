function path = escapePathForShell(path)
% path = escapePathForShell(path)
% Escape a path to a file or directory for embedding within a shell command
% passed to cmd or unix.

path = strrep(path, ' ', '\ ');
%path = ['"' path '"'];