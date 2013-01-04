function addPathRecursive(folder)
% addPathRecursive(folder)
% Adds a folder and all non-hidden subdirectories to the path

pathstr = genpath(folder);
addpath(pathstr);

return;

% old inefficient way of doing this via recursion
% here in case useful

list = dir(folder);

addpath(folder);

for i = 1:length(list)
	if ~list(i).isdir || strcmp(list(i).name(1), '.')
		continue;
	end

	addPathRecursive(fullfile(folder, list(i).name));
end

end
