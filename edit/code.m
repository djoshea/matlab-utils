function code(varargin)
%CODE Open file(s) in active VSCode instance
%   CODE(FILE) opens FILE in VSCode, searching MATLAB path if needed
%   CODE(FILE1, FILE2, ...) opens multiple files in VSCode
%
%   The function will search for files in the following order:
%     1. As a direct file path (absolute or relative)
%     2. With .m extension added (if not present)
%     3. On the MATLAB path using which()
%
%   Examples:
%       code('myfile.m')           % Open file in current directory
%       code('myfile')             % Adds .m extension automatically
%       code('plot')               % Finds plot.m on MATLAB path
%       code('script1', 'script2') % Open multiple files
%
%   Note: Requires VSCode 'code' command to be in PATH
%   To install: Open VSCode Command Palette (Cmd+Shift+P) and run
%   "Shell Command: Install 'code' command in PATH"

    arguments (Repeating)
        varargin {mustBeTextScalar}
    end

    if isempty(varargin)
        error('code:NoFiles', 'At least one file name must be provided');
    end

    % Check if 'code' command is available
    [status, ~] = system('which code');
    if status ~= 0
        error('code:CommandNotFound', [...
            'VSCode ''code'' command not found in PATH.\n' ...
            'To install:\n' ...
            '  1. Open VSCode\n' ...
            '  2. Press Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows/Linux)\n' ...
            '  3. Type "Shell Command: Install ''code'' command in PATH"\n' ...
            '  4. Select and run the command']);
    end

    % Resolve each file path (checking MATLAB path if needed)
    resolvedFiles = cell(size(varargin));
    for i = 1:length(varargin)
        resolvedFiles{i} = resolveFile(varargin{i});
    end

    % Build command to open all files
    % Use absolute paths to ensure VSCode opens the right files
    files = cellfun(@(f) ['''' char(f) ''''], resolvedFiles, 'UniformOutput', false);
    cmd = ['code ' strjoin(files, ' ')];

    % Execute command
    [status, output] = system(cmd);

    if status ~= 0
        error('code:OpenFailed', 'Failed to open file(s) in VSCode: %s', output);
    end
end

function absPath = resolveFile(name)
    % Resolve file name to absolute path, searching MATLAB path if needed
    %
    % Strategy:
    %   1. Check if file exists as-is (absolute or relative path)
    %   2. Try adding .m extension if not present
    %   3. Search MATLAB path using which()

    % Try 1: File exists as-is
    if isfile(name)
        absPath = absolutePath(name);
        return;
    end

    % Try 2: Add .m extension if not present
    [~, ~, ext] = fileparts(name);
    if isempty(ext)
        nameWithExt = [name '.m'];
        if isfile(nameWithExt)
            absPath = absolutePath(nameWithExt);
            return;
        end
    else
        nameWithExt = name;
    end

    % Try 3: Search MATLAB path
    pathResult = which(nameWithExt);
    if ~isempty(pathResult)
        absPath = pathResult;
        return;
    end

    % Also try original name without extension on path
    if ~isempty(ext)
        pathResult = which(name);
        if ~isempty(pathResult)
            absPath = pathResult;
            return;
        end
    end

    % Not found anywhere
    error('code:FileNotFound', 'File not found: %s', name);
end

function absPath = absolutePath(filepath)
    % Convert relative path to absolute path
    if ~isAbsolute(filepath)
        absPath = fullfile(pwd, filepath);
    else
        absPath = filepath;
    end
end

function tf = isAbsolute(filepath)
    % Check if path is absolute
    if ispc
        % Windows: starts with drive letter (C:\) or UNC (\\)
        tf = ~isempty(regexp(filepath, '^[A-Za-z]:\\|^\\\\', 'once'));
    else
        % Unix/Mac: starts with /
        tf = startsWith(filepath, '/');
    end
end
