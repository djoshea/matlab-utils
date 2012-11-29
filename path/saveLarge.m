function saveLarge(fname, varargin)

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

if(totalBytes > 1.99e9)
    % use version 7.3 when bigger than 2 GB
    try
        cmd = sprintf('save(''%s'', ''-v7.3'', %s %s)', fname, flags, varString);
        saveV6 = false;
    catch
        saveV6 = true;
    end
else
    saveV6 = true;
end

if saveV6
    % else use v6 as it's uncompressed and faster
    cmd = sprintf('save(''%s'', ''-v6'', %s %s)', fname, flags, varString);
end

try
	evalin('caller', cmd);
catch exc
	fprintf('\n');
	fprintf('ERROR saving %s to disk\n', fname)
	fprintf('Message: %s', exc.message);
end

% grant group write access
unix(['chmod g+rw ' fname]);

end
