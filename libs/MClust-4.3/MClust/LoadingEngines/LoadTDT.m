function [t, wv] = LoadTDT(varargin)

global hTTI;
global TTICurrentServer TTICurrentTank TTICurrentBlock TTICurrentEvent TTICurrentChannel;

TTI_ext = '.mc';

filename = '';
flag = 0;
if nargin == 1
    filename = varargin;
elseif nargin == 2
    if strcmp(varargin{1}, 'get')
        switch (varargin{2})
            case 'ChannelValidity'
                t = [true true true true]; return;
            case 'ExpectedExtension'
                t = ''; return;
            case 'UseFileDialog'
                t = false; return;
            case 'filenames'
                % launch TTankInterface
                hTTI = figure;
                TTI;
                uiwait(hTTI)

                % create file name
                % first, the directory name, which is the block location on disk
                wv = sprintf('%s\\%s\\',TTICurrentTank, TTICurrentBlock);
                % then the file name
                t = sprintf('%s_%s_%d%s', TTICurrentBlock, TTICurrentEvent, TTICurrentChannel, TTI_ext);
                
                return;
            otherwise
                error('Unknown get condition.');
        end
    else
        error('2 argins requires "get" as the first argument.');
    end
elseif nargin == 3
    %filename = varargin{1};
    range = varargin{2};
    flag = varargin{3};
end

if ~ismember(flag, 0:5), error('bad flag'), end

% get data parameters from filename
[directory file ext] = fileparts(filename{1});
[TANK BLOCK] = fileparts(directory);
s = regexp(file, '_', 'split');
EVENT = s{2};
CHANNEL = str2double(s{3});
data = TDT2mat(TANK, BLOCK, 'TYPE', 3, 'VERBOSE', 0, 'SERVER', TTICurrentServer);

% get data and timestamps
chan = data.snips.(EVENT).chan;
ind = chan == CHANNEL;
if sum(ind) == 0
    warning(['no data found in ' TANK ' ' BLOCK ' ' EVENT ' channel ' num2str(CHANNEL)]);
end
wv = data.snips.(EVENT).data(ind, :);

% zero pad the waveforms so they are 32 pts long
z = zeros(size(wv,1),1);
wv = [z wv z];

t = data.snips.(EVENT).ts(ind);

% handle input flag
if flag == 1
    % range is timestamp list
    ind = ismember(t, range);
    t = t(ind);
    wv = wv(ind,:);
elseif flag == 2
    % range is record number
    t = t(range);
    wv = wv(range,:);
elseif flag == 3
    % range is [start timestamp, stop timestamp]
    ind = (t >= range(1) & t <= range(2));
    t = t(ind);
    wv = wv(ind,:);
elseif flag == 4
    % range is [start record, stop record]
    ind = range(1):range(2);
    t = t(ind);
    wv = wv(ind,:);
elseif flag == 5
    t = numel(t);
    wv = [];
end
wv = reshape(wv, size(wv,1), 4, 32);

end
