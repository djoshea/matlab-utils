function data = TDT2mat(tank, block, varargin)
%TDT2MAT  TDT tank data extraction.
%   data = TDT2mat(TANK, BLOCK), where TANK and BLOCK are strings, retrieve
%   all data from specified block in struct format.
%
%   data.epocs      contains all epoc store data (onsets, offsets, values)
%   data.snips      contains all snippet store data (timestamps, channels,
%                   and raw data)
%   data.streams    contains all continuous data (sampling rate and raw
%                   data)
%   data.info       contains additional information about the block
%
%   data = TDT2mat(TANK, BLOCK,'parameter',value,...)
%
%   'parameter', value pairs
%      'SERVER'     string, data tank server (default = 'Local')
%      'T1'         scalar, retrieve data starting at T1 (default = 0 for
%                       beginning of recording)
%      'T2'         scalar, retrieve data ending at T2 (default = 0 for end
%                       of recording)
%      'SORTNAME'   string, specify sort ID to use when extracting snippets
%      'VERBOSE'    boolean, set to false to disable console output
%      'TYPE'       array of scalars, specifies what type of data stores to
%                       retrieve from the tank
%                   1: all (default)
%                   2: epocs
%                   3: snips
%                   4: streams
%                   5: scalars
%                   example:
%                       data = TDT2mat('MyTank','Block-1','Type',[1 2]);
%                           > returns only epocs and snips
%      'RANGES'     array of valid time range column vectors
%      'NODATA'     boolean, set to true to only return timestamps,
%                       channels, and sort codes for snippets, no waveform
%                       data
%

data = struct('epocs', [], 'snips', [], 'streams', [], 'scalars', []);

% defaults
T1       = 0;
T2       = 0;
RANGES   = [];
VERBOSE  = 1;
TYPE     = 1;
SORTNAME = 'TankSort';
SERVER   = 'Local';
NODATA   = 0;

MAXEVENTS = 1e6;
MAXCHANNELS = 1024;

% parse varargin
for i = 1:2:length(varargin)
    eval([upper(varargin{i}) '=varargin{i+1};']);
end

if TYPE == 1, TYPE = 1:5; end
ReadEventsOptions = 'ALL';
if NODATA, ReadEventsOptions = 'NODATA'; end

% create TTankX object
h = figure('Visible', 'off', 'HandleVisibility', 'off');
TTX = actxcontrol('TTank.X', 'Parent', h);

% connect to server
if TTX.ConnectServer(SERVER, 'Me') ~= 1
    close(h)
    error(['Problem connecting to server: ' SERVER])
end

% open tank
if TTX.OpenTank(tank, 'R') ~= 1
    TTX.ReleaseServer;
    close(h);
    error(['Problem opening tank: ' tank]);
end

% select block
if TTX.SelectBlock(['~' block]) ~= 1
    block_name = TTX.QueryBlockName(0);
    block_ind = 1;
    while strcmp(block_name, '') == 0
        block_ind = block_ind+1;
        block_name = TTX.QueryBlockName(block_ind);
        if strcmp(block_name, block)
            error(['Block found, but problem selecting it: ' block]);
        end
    end
    error(['Block not found: ' block]);
end

% set info fields
start = TTX.CurBlockStartTime;
stop = TTX.CurBlockStopTime;
total = stop-start;

data.info.tankpath = TTX.GetTankItem(tank, 'PT');
data.info.blockname = block;
data.info.date = TTX.FancyTime(start, 'Y-O-D');
data.info.starttime = TTX.FancyTime(start, 'H:M:S');
data.info.stoptime = TTX.FancyTime(stop, 'H:M:S');
if stop > 0
    data.info.duration = TTX.FancyTime(total, 'H:M:S');
end

if VERBOSE
    fprintf('\nTank Name:\t%s\n', tank);
    fprintf('Tank Path:\t%s\n', data.info.tankpath);
    fprintf('Block Name:\t%s\n', data.info.blockname);
    fprintf('Start Date:\t%s\n', data.info.date);
    fprintf('Start Time:\t%s\n', data.info.starttime);
    if stop > 0
        fprintf('Stop Time:\t%s\n', data.info.stoptime);
        fprintf('Total Time:\t%s\n', data.info.duration);
    else
        fprintf('==Block currently recording==\n');
    end
end

% set global tank server defaults
TTX.SetGlobalV('WavesMemLimit',1e9);
TTX.SetGlobalV('MaxReturn',MAXEVENTS);
TTX.SetGlobalV('T1', T1);
TTX.SetGlobalV('T2', T2);

ranges_size = size(RANGES,2);

if ranges_size > 0
    data.time_ranges = RANGES;
end

% parse stores
lStores = TTX.GetEventCodes(0);
for i = 1:length(lStores)
    name = TTX.CodeToString(lStores(i));
    if VERBOSE, fprintf('\nStore Name:\t%s\n', name); end
    
    TTX.GetCodeSpecs(lStores(i));
    type = TTX.EvTypeToString(TTX.EvType);
    
    if bitand(TTX.EvType, 33025) == 33025 % catch RS4 header (33073)
        type = 'Stream';
    end
    
    if VERBOSE, fprintf('EvType:\t\t%s\n', type); end
    
    switch type
        case 'Strobe+'
            if ~any(TYPE==2), continue; end
            if VERBOSE, fprintf('Data Size:\t%d\n',TTX.EvDataSize), end
            
            if ranges_size > 0
                for ff = 1:ranges_size
                    d = TTX.GetEpocsV(name, RANGES(1, ff), RANGES(2, ff), MAXEVENTS)';
                    if ~any(isnan(d))
                        data.epocs.(name).data{ff} = d(:,1);
                        data.epocs.(name).onset{ff} = d(:,2);
                        if d(:,3) == zeros(size(d(:,3)))
                            d(:,3) = [d(2:end,2); inf];
                        end
                        data.epocs.(name).offset{ff} = d(:,3);
                    end
                end
                if ~isfield(data.epocs, name), continue; end
                data.epocs.(name).data = cat(1, data.epocs.(name).data{:});
                data.epocs.(name).onset = cat(1, data.epocs.(name).onset{:});
                data.epocs.(name).offset = cat(1, data.epocs.(name).offset{:});
                
                % get rid of Infs in middle of data set
                ind = strfind(data.epocs.(name).offset', Inf);
                ind = ind(ind < size(data.epocs.(name).offset,1));
                data.epocs.(name).offset(ind) = data.epocs.(name).onset(min(size(data.epocs.(name).onset,1),ind+1));
            else
                d = TTX.GetEpocsV(name, T1, T2, MAXEVENTS)';
                if numel(d) == 1  % store exists but there are no timestamps (nan?)
                    data.epocs.(name).data = d;
                    data.epocs.(name).onset = d;
                    data.epocs.(name).offset = d;
                else
                    data.epocs.(name).data = d(:,1);
                    data.epocs.(name).onset = d(:,2);
                    if d(:,3) == zeros(size(d(:,3)))
                        d(:,3) = [d(2:end,2); inf];
                    end
                    data.epocs.(name).offset = d(:,3);
                end
            end
            data.epocs.(name).name = name;
        case 'Scalar'
            if ~any(TYPE==5), continue; end
            if VERBOSE, fprintf('Data Size:\t%d\n',TTX.EvDataSize), end
            if ranges_size > 0
                for ff = 1:ranges_size
                    TTX.SetGlobalV('T1', RANGES(1, ff));
                    TTX.SetGlobalV('T2', RANGES(2, ff));
                    
                    N = TTX.ReadEventsSimple(name);
                    if N > 0
                        data.scalars.(name).data{ff} = TTX.ParseEvV(0, N)'';
                        data.scalars.(name).ts{ff} = TTX.ParseEvInfoV(0, N, 6)'';
                        channels = TTX.ParseEvInfoV(0, N, 4)'';
                        
                        % reorganize data array by channel
                        maxchannel = max(channels);
                        newdata = zeros(maxchannel, numel(data.scalars.(name).data{ff})/maxchannel);
                        for xx = 1:maxchannel
                            arr = data.scalars.(name).data{ff};
                            newdata(xx,:) = arr(channels == xx);
                        end
                        data.scalars.(name).data{ff} = newdata;
                        
                        % decimate timestamps, only use channel 1
                        os = data.scalars.(name).ts{ff};
                        data.scalars.(name).ts{ff} = os(channels == 1);
                        clear newdata;
                    end
                end
                % reset T1, T2
                TTX.SetGlobalV('T1', T1);
                TTX.SetGlobalV('T2', T2);
                
                if ~isfield(data.scalars, name), continue; end
                data.scalars.(name).data = cat(2, data.scalars.(name).data{:});
                data.scalars.(name).ts = cat(2, data.scalars.(name).ts{:});
            else
                N = TTX.ReadEventsSimple(name);
                if N > 0
                    data.scalars.(name).data = TTX.ParseEvV(0, N)'';
                    data.scalars.(name).ts = TTX.ParseEvInfoV(0, N, 6)'';
                    channels = TTX.ParseEvInfoV(0, N, 4)'';
                    
                    % organize data by channel
                    maxchannel = max(channels);
                    newdata = zeros(maxchannel, numel(data.scalars.(name).data)/maxchannel);
                    for xx = 1:maxchannel
                        newdata(xx,:) = data.scalars.(name).data(channels == xx);
                    end
                    data.scalars.(name).data = newdata;
                    
                    % decimate timestamps, only use channel 1
                    data.scalars.(name).ts = data.scalars.(name).ts(channels == 1);
                    clear newdata;
                end
            end
            if N > 0, data.scalars.(name).name = name; end
        case 'Stream'
            if ~any(TYPE==4), continue; end
            if VERBOSE, fprintf('Samp Rate:\t%f\n',TTX.EvSampFreq), end
            
            % read some events to see how many channels there are
            N = TTX.ReadEventsV(10000, name, 0, 0, 0, 0, 'NODATA');
            if (N < 1), continue; end
            num_channels = max(TTX.ParseEvInfoV(0, N, 4));
            if VERBOSE, fprintf('Channels:\t%d\n', num_channels), end
            
            % loop through ranges, if there are any
            if ranges_size > 0
                for ff = 1:ranges_size
                    TTX.SetGlobalV('T1', RANGES(1, ff));
                    TTX.SetGlobalV('T2', RANGES(2, ff));
                    d = TTX.ReadWavesV(name)';
                    if numel(d) > 1
                        data.streams.(name).filtered{ff} = d;
                    end
                end
                % reset when done
                TTX.SetGlobalV('T1', T1);
                TTX.SetGlobalV('T2', T2);
            else
                data.streams.(name).data = TTX.ReadWavesV(name)';
                nancheck = numel(data.streams.(name).data) == 1;
                if nancheck
                    chunk_size = 2;  % try chunk size 1/2 length
                    if T2 > 0
                        approx_length = ceil((T2-T1) * TTX.EvSampFreq); % samples
                    else
                        approx_length = ceil(total * TTX.EvSampFreq); % samples
                    end
                    data.streams.(name).data = zeros(num_channels,approx_length);
                end
                while nancheck
                    step_size = approx_length / TTX.EvSampFreq /chunk_size;
                    warning('ReadWavesV returned NaN for %s, attempting step size %.2f', name, step_size);
                    if step_size < 0.1, error('step size < .1 second, adjust WavesMemLimit'), end
                    ind = 1;
                    for c = 0:chunk_size-1
                        TTX.SetGlobalV('T1', T1 + c*step_size);  % TODO: make this relative to T1?
                        TTX.SetGlobalV('T2', (c+1)*step_size);
                        temp_data = TTX.ReadWavesV(name)';
                        nancheck = numel(temp_data) == 1;
                        if nancheck
                            break;
                        end
                        data.streams.(name).data(:,ind:ind+size(temp_data,2)-1) = temp_data;
                        ind = ind + size(temp_data,2);
                    end
                    chunk_size = chunk_size * 2;
                end
            end
            data.streams.(name).fs = TTX.EvSampFreq;
            data.streams.(name).name = name;
        case 'Snip'
            if ~any(TYPE==3), continue; end
            if VERBOSE, fprintf('Samp Rate:\t%f\n',TTX.EvSampFreq), end
            if VERBOSE, fprintf('Data Size:\t%d\n',TTX.EvDataSize), end
            
            TTX.SetUseSortName(SORTNAME);
            
            if ranges_size > 0
                for ff = 1:ranges_size
                    N = TTX.ReadEventsV(MAXEVENTS, name, 0, 0, RANGES(1, ff), RANGES(2, ff), ReadEventsOptions);
                    if N > 0
                        if N == MAXEVENTS
                            warning('Max Total Events (%d) Reached during range extraction, contact TDT\n', MAXEVENTS);
                        else
                            if ~NODATA
                                data.snips.(name).data{ff} = TTX.ParseEvV(0, N)';
                            else
                                data.snips.(name).data{ff} = [];
                            end
                            data.snips.(name).chan{ff} = TTX.ParseEvInfoV(0, N, 4)';
                            data.snips.(name).sortcode{ff} = TTX.ParseEvInfoV(0, N, 5)';
                            data.snips.(name).ts{ff} = TTX.ParseEvInfoV(0, N, 6)';
                        end
                    end
                end
                if ~isfield(data.snips, name), continue; end
                if ~NODATA
                    data.snips.(name).data = cat(1, data.snips.(name).data{:});
                else
                    data.snips.(name).data = [];
                end
                data.snips.(name).chan = cat(1, data.snips.(name).chan{:});
                data.snips.(name).sortcode = cat(1, data.snips.(name).sortcode{:});
                data.snips.(name).ts = cat(1, data.snips.(name).ts{:});
            else
                N = TTX.ReadEventsV(MAXEVENTS, name, 0, 0, T1, T2, ReadEventsOptions);
                if N > 0
                    if N == MAXEVENTS
                        if VERBOSE, fprintf('Max Total Events (%d) Reached. Looping through channels\n', MAXEVENTS), end
                        firstchan = 1;
                        skipct = 0;
                        for chan = 1:MAXCHANNELS
                            NCHAN = TTX.ReadEventsV(MAXEVENTS, name, chan, 0, T1, T2, ReadEventsOptions);
                            if firstchan
                                if VERBOSE, fprintf('Reading channel %d', chan), end
                            else
                                if VERBOSE, fprintf(' %d', chan), end
                            end
                            if NCHAN > 0
                                if NCHAN == MAXEVENTS
                                    warning(sprintf('Max Events (%d) reached on channel %d. Looping through time..\n', MAXEVENTS, chan));
                                    time_slices = 10;
                                    if T2 < 0.00001, T2 = total + 3; end
                                    dT = (T2-T1)/time_slices;
                                    currT1 = T1;
                                    currT2 = currT1+dT;
                                    for dt = 1:time_slices+1
                                        NTIME = TTX.ReadEventsV(MAXEVENTS, name, chan, 0, currT1, currT2, ReadEventsOptions);
                                        if NTIME > 0
                                            if NTIME == MAXEVENTS
                                                warning(sprintf('Max Events (%d) reached on channel %d time slice %d, contact TDT\n', MAXEVENTS, chan, dt));
                                            else
                                                if firstchan
                                                    if ~NODATA
                                                        data.snips.(name).data = TTX.ParseEvV(0, NTIME)';
                                                    end
                                                    data.snips.(name).chan = TTX.ParseEvInfoV(0, NTIME, 4)';
                                                    data.snips.(name).sortcode = TTX.ParseEvInfoV(0, NTIME, 5)';
                                                    data.snips.(name).ts = TTX.ParseEvInfoV(0, NTIME, 6)';
                                                    firstchan = 0;
                                                else
                                                    if ~NODATA
                                                        data.snips.(name).data = cat(1, data.snips.(name).data, TTX.ParseEvV(0, NTIME)');
                                                    end
                                                    data.snips.(name).chan = cat(1, data.snips.(name).chan, TTX.ParseEvInfoV(0, NTIME, 4)');
                                                    data.snips.(name).sortcode = cat(1, data.snips.(name).sortcode, TTX.ParseEvInfoV(0, NTIME, 5)');
                                                    data.snips.(name).ts = cat(1, data.snips.(name).ts, TTX.ParseEvInfoV(0, NTIME, 6)');
                                                end
                                            end
                                        end
                                        currT1 = currT2;
                                        currT2 = currT1+dT;
                                    end
                                else
                                    if firstchan
                                        if ~NODATA
                                            data.snips.(name).data = TTX.ParseEvV(0, NCHAN)';
                                        end
                                        data.snips.(name).chan = TTX.ParseEvInfoV(0, NCHAN, 4)';
                                        data.snips.(name).sortcode = TTX.ParseEvInfoV(0, NCHAN, 5)';
                                        data.snips.(name).ts = TTX.ParseEvInfoV(0, NCHAN, 6)';
                                        firstchan = 0;
                                    else
                                        if ~NODATA
                                            data.snips.(name).data = cat(1,data.snips.(name).data, TTX.ParseEvV(0, NCHAN)');
                                        end
                                        data.snips.(name).chan = cat(1,data.snips.(name).chan, TTX.ParseEvInfoV(0, NCHAN, 4)');
                                        data.snips.(name).sortcode = cat(1,data.snips.(name).sortcode, TTX.ParseEvInfoV(0, NCHAN, 5)');
                                        data.snips.(name).ts = cat(1,data.snips.(name).ts, TTX.ParseEvInfoV(0, NCHAN, 6)');
                                    end
                                    if mod(chan, 16) == 0 && VERBOSE
                                        fprintf('\n')
                                    end
                                end
                                % reset skip counter
                                skipct = 0;
                            else
                                skipct = skipct + 1;
                                if skipct == 10
                                    if VERBOSE, fprintf('\nNo events found on last 10 channels, exiting loop\n'), end
                                    break;
                                end
                            end
                        end
                        % sort the data based on timestamp
                        [data.snips.(name).ts, ind] = sort(data.snips.(name).ts);
                        data.snips.(name).chan = data.snips.(name).chan(ind);
                        data.snips.(name).sortcode = data.snips.(name).sortcode(ind);
                        if ~NODATA
                            data.snips.(name).data = data.snips.(name).data(ind,:);
                        else
                            data.snips.(name).data = [];
                        end
                    else
                        if ~NODATA
                            data.snips.(name).data = TTX.ParseEvV(0, N)';
                        else
                            data.snips.(name).data = [];
                        end
                        data.snips.(name).chan = TTX.ParseEvInfoV(0, N, 4)';
                        data.snips.(name).sortcode = TTX.ParseEvInfoV(0, N, 5)';
                        data.snips.(name).ts = TTX.ParseEvInfoV(0, N, 6)';
                    end
                end
            end
            if N > 0
                data.snips.(name).name = name;
                data.snips.(name).sortname = SORTNAME;
            end
    end
end

% check for SEV files
% TODO: RANGES for SEV files?
if any(TYPE==4)
    
    blockpath = sprintf('%s%s\\%s\\', data.info.tankpath, tank, block);
    
    file_list = dir([blockpath '*.sev']);
    if length(file_list) < 3
        if VERBOSE, disp(['info: no sev files found in ' blockpath]), end
    else
        eventNames = SEV2mat(blockpath, 'JUSTNAMES', true, 'VERBOSE', false);
        for i = 1:length(eventNames)
            if ~isfield(data.streams, eventNames{i})
                if VERBOSE
                    fprintf('SEVs found in %s.\nrunning SEV2mat to extract %s', ...
                        blockpath, eventNames{i})
                end
                sev_data = SEV2mat(blockpath, 'EVENTNAME', eventNames{i}, 'VERBOSE', VERBOSE);
                data.streams.(eventNames{i}) = sev_data.eventNames{i};
            end
        end
    end
end

TTX.CloseTank;
TTX.ReleaseServer;

close(h);