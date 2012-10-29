function fileList = filePicker(list, varargin)
% fileList = filePicker(list, varargin)
% 	list can be one of:
% 		file name (string): checks existence, returns [] and prints error if doesn't exist
% 		list of names (cell array of strings}: checks existence, returns [] and prints error if any doesn't exist
% 		wildcard selector (string): if contains *, allows for wildcard selection of files
% 		directory name (string): loads all files in that directory
% 		[] (empty): prompts for single file (multiple = false) or multiple files (multiple = true)
%
% 	optional args:
% 		filters : cell array of strings, see uigetfile specifications
% 		multiple : boolean
% 		prompt : string for dialog title
% 		startDir : initial starting point for uigetfile
% 		selectMode: 'dir' or 'files', dir selects

def.filterList = {'*', 'All Files'};
def.multiple = true;
def.prompt = 'Choose File';
def.startDir = pwd;
def.selectMode = 'file'; % 'file' or 'dir' which selects all files in a directory automatically
def.extensionFilter = '*'; % something like '.txt' returns only those files chosen that matched .txt when dir is specified
assignargs(def, varargin);

if(multiple)
	multiSelect = 'on';
else
	multiSelect = 'off';
end

% first check whether the user provided the file info as a list
if(~exist('list', 'var') || isempty(list))
    % nothing specified, prompt for one
    if(strcmp(selectMode, 'dir'))
        % choose directory to load htbs from
        list = uigetdir(startDir, prompt);
        if(isnumeric(list))
            fileList = [];
            return;
        end
        
    elseif(strcmp(selectMode, 'file'))
        % prompt for individual file selection
        [filename pathname] = uigetfile(filterList, prompt, startDir, 'MultiSelect', multiSelect);
        if(isnumeric(filename))
            fileList = [];
            return;
        end
        
        if(ischar(filename))
            list = fullfile(pathname,filename);
        else
            list = cell(length(filename), 1);
            for iFile = 1:length(filename)
                list{iFile} = fullfile(pathname, filename{iFile});
            end
        end

    else        
        error('Unknown selectMode "%s"', selectMode);
    end
end

% now the filename / dir name / list of files should be in list
if(ischar(list))
	list = {list};
end

fileList = {};
for i = 1:length(list)
    % try making into a directory by merging with startDir
    if(exist(fullfile(startDir, list{i}), 'dir'))
        list{i} = fullfile(startDir, list{i});
    end
    
    if(exist(list{i}, 'dir') && strcmp(selectMode,'file')) 
        % get list of files in the dir
        fileInfo = dir(fullfile(list{i}, extensionFilter));
        fileNamesFull = cellfun(@(name) fullfile(list{i}, name), {fileInfo.name}, 'UniformOutput', false);
        fileList = cat(2,fileList,fileNamesFull);
        
    elseif(exist(list{i}, 'dir') && strcmp(selectMode, 'dir'))
        % return the actual directory directly
        fileList = list{i};
    elseif(exist(list{i}, 'file'))
        % htb is a filename
        fileList = cat(2,fileList,{list{i}});
	elseif(strfind(list{i}, '*'))
		% wildcard search
		fileInfo = dir(list{i});
        fileNamesFull = cellfun(@(name) fullfile(fileparts(list{i}), name), ...
            {fileInfo.name}, 'UniformOutput', false); % append file path on
		fileList = cat(2,fileList,fileNamesFull);
	end
end


% truncate to first result if not multiple
if(~multiple)
	fileList = fileList{1};
end

