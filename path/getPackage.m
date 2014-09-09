function package = getPackage(stackOffset)

if nargin < 1
    stackOffset = 0;
end

files = dbstack('-completenames');
path = fileparts(files(2 + stackOffset).file);
package = '';

while ~isempty(path)
    [path, name] = fileparts(path);
    if strcmp(name(1), '+')
        if isempty(package)
            package = name(2:end);
        else
            package = sprintf('%s.%s', name(2:end), package);
        end
    else
        break;
    end
end

end