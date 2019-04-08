function saveLarge(fname, varargin)
fname = char(fname);
vars = evalin('caller', 'whos');

if isempty(varargin)
    error('Please provide the names of variables to save');
end

varnames = varargin;
if strcmp(varnames{1}, '-struct')
    flags = '''-struct'', ';
    varnames = varnames(2:end);
else
    flags = ' ';
end

totalBytes = 0;
varString = '';
for i = 1:length(varnames)
    if strcmp(varnames{i}, '-struct')
        asStruct = true;
        continue;
    end
    
    ind = find(strcmp(varnames{i}, {vars.name}));
    if isempty(ind)
        error('Variable %s does not exist', varnames{i});
    end

    totalBytes = totalBytes + vars(ind).bytes;

    varString = [varString sprintf('''%s''', varnames{i})];
    if i < length(varnames)
        varString = [varString ','];
    end
end

success = false;

if(totalBytes < 1.99e9)
    % else use v6 as it's uncompressed and faster
    cmd = sprintf('save(''%s'', ''-v6'', %s %s)', fname, flags, varString);
    
    try
        evalin('caller', cmd);
        success = true;
    catch
        success = false;
    end
end

if ~success
    % use version 7.3 when bigger than 2 GB or if v6 fails
    try
        cmd = sprintf('save(''%s'', ''-v7.3'', %s %s)', fname, flags, varString);
        evalin('caller', cmd);
    catch
        error('Could not save %s to disk using v6 or v7.3\n', fname)
    end
end

% grant group write access
unix(['chmod g+rw ' fname]);

end
