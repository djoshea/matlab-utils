function fnames = listFilesInDirectory(path, ext)
% returns a lexicographically organized list of files with a certain extension in a certain directory

if ext(1) ~= '.'
    ext = ['.' ext];
end

searchStr = fullfile(path, ['*' ext]);
matches = dir(searchStr);
names = {matches.name};

% remove files whose name begins with .
hidden = cellfun(@(name) strcmp('.', name(1)), names);
names = names(~hidden);

fnames = cellfun(@(name) fullfile(path, name), names, 'UniformOutput', false);

end
