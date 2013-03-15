function vim(varargin)
% VIM Edit file using vim. 
%   VIM(file) edits file in vim using the first server returned by vim --serverlist.
%   File must exist somewhere on the path. Vim must have been opened using --servername
%   flag in order to be registered as a server.
%
%   VIM(file, server) edits file using a specific vim server. Server is either the name
%   of that server or the numeric index of the server in the --serverlist.
%
%   VIM --serverlist returns the list of vim instances in the serverlist
%
%   Example
%     vim helloWorld % open helloWorld.m in the first vim server in serverlist
%     vim --serverlist % list open registered vim instances 
%     vim helloWorld VIM3 % open helloWorld.m in vim with servername VIM3
%

    p = inputParser;
    p.addRequired('file', @ischar);
    p.addOptional('server', 1, @(x) ischar(x) || isscalar(x)); 
    p.parse(varargin{:});
    file = p.Results.file;
    server = p.Results.server;
    
    if strcmp(file, '--serverlist') 
        getVimServerList(true);
        return;
    end

    file = which(file);
    if isempty(file)
        fprintf('Could not find file %s\n', file);
        return;
    end

    if isempty(server)
        server = 1;
    end
        
    list = getVimServerList();
    
    if ischar(server)
        numServer = str2double(server);
        if ~isnan(numServer)
            server = numServer;
        end
    end
    
    if isnumeric(server)
        if isempty(list)
            fprintf('No vim servers found. Open vim using --servername flag\n');
            return;
        end
        
        if length(list) < server
            fprintf('Server index out of range. Server list is:\n');
            getVimServerList(true);
            return;
        end
        
        server = list{server};
    else
        if ~ismember(server, list)
            fprintf('Server %s not found in list:\n', server);
            getVimServerList(true);
            return;
        end
    end 
    
    cmd = sprintf('vim --servername %s --remote %s', server, file);
    [status result] = system(cmd);
    if status
        fprintf('Error opening vim:\n');
        fprintf(result);
        return;
    end
end

function list = getVimServerList(printList)
    [status result] = system('vim --serverlist'); 
    if isempty(result)
        list = {};
    else
        list = strsplit(result, '\n');
    end
    if nargin > 0 && printList
        if isempty(list)
            fprintf('No instances in serverlist\n');
        else
            for i = 1:length(list)
                fprintf('%2d : %s\n', i, list{i});
            end
        end
    end
end

function tokens = strsplit(str, separator)
    % creates a string by splitting the elements of strCell, separated by the string
    % % in separator, ignoring spaces 
    % % internally uses repeated strtok calls to do the splitting
    % % e.g. str = '3,4, 5', separator = ',' [ default ] --> strCell = {'3','4','5'}
    %
    if nargin < 2
        separator = ',';
    end

    results = textscan(str, '%s', 'Delimiter', separator);
    tokens = results{1};

end

