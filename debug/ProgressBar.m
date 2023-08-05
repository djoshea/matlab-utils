classdef ProgressBar < handle
% Generates a progress bar which uses ANSI color codes to colorize output
% in a color terminal. The background color steadily advances along from
% left to right beneath a custom message and progress percentage string.
%
% Parallel mode: this class works in spmd and parfor blocks, if
% .enableParallel is called BEFORE the spmd/parfor block. Only the thread
% with task id==1 will output to the screen.
%
% Usage:
%   pbar = ProgressBar('Message goes here', nThingsToProcess);
%   for i = 1:nThingsToProcess
%       pbar.update(i, [optional message update]);
%       ...
%   end
%   pbar.finish([optional final message]);
%
% Parallel usage: (sort of works)
%   pbar = ProgressBar('Message goes here', nThingsToProcess);
%   pbar.enableParallel();
%   for i = 1:nThingsToProcess
%       ... % put operations BEFORE update
%       pbar.update(i, [optional message update]);
%   end
%   pbar.finish([optional final message]);
%
% Demonstration:
%   ProgressBar.demo();
%   ProgressBar.demoNested();
%   ProgressBar.demoParallel();
%
%

    properties
        active = true;
    end

    properties(SetAccess=protected)
        message
        n = 0; % last value
        N
        cols
        trueColor = false;
        firstUpdate
        timeStart

        lastCalled

        usingTerminal
        usingNotebook

        lastCalledItermStatus
        usingItermStatus = false;

        % enable for parallel for loops? see .enableParallel / disableParallel
        parallel = false;
        fnamePrefix

%         objWorker

        nCompleteByWorker

        lastNBoxes = 0;
        lastNSpaces = 0;

        trueCmap;

        textprogressStrCR = '';
    end

    properties(Constant)
        minInterval = 0.1; % seconds
        minIntervalItermStatus = 1;
    end

    methods
        function pbar = ProgressBar(varargin)
            % ProgressBar(N, message, sprintf_varargin for message)
            % ProgressBar(active?, N, message, sprintf_varargin for message)

            args = varargin;
            if numel(args) >= 1
                if islogical(args{1}) && isnumeric(args{2})
                    pbar.active = args{1};
                    args = args(2:end);
                end
            end
            
            if numel(args) >= 1
                N = args{1};
                pbar.N = double(N);
                args = args(2:end);
            else
                pbar.N = 1;
            end

            if numel(args) >= 1
                pbar.message = sprintf(args{:});
            else
                pbar.message = '';
            end
            
            % use simple version in desktop mode  not inside jupyter kernel
            outputMode = getMatlabOutputMode();
            pbar.usingTerminal = strcmp(outputMode, 'terminal');
            pbar.usingNotebook = strcmp(outputMode, 'notebook');
%             pbar.usingNotebook = false;

            [~, pbar.cols] = ProgressBar.getTerminalSize();
%             pbar.trueColor = (~isempty(getenv('ITERM_PROFILE')) || pbar.usingNotebook);
            pbar.trueColor = true;

            if pbar.trueColor

                hsv = ones(pbar.cols, 3);
                hsv(:, 1) = 0.5;
                hsv(:, 2) = 0.6;
                b = 0.5 * (1+sin((1:pbar.cols) / 8));
                x = 0.3;
                b = b*x + 0.95-x;
                hsv(:, 3) = b;
                cmap = winter(ceil(pbar.cols/2));
                pbar.trueCmap = [cmap; flipud(cmap)];
            end

            if ismac && ~usejava('desktop') && exist(fullfile(getenv('HOME'), '.iterm2/it2setkeylabel'), 'file')
                pbar.usingItermStatus = true;
            else
                pbar.usingItermStatus = false;
            end

            pbar.firstUpdate = true;
            pbar.timeStart = clock;
            pbar.lastNBoxes = 0;
            pbar.lastNSpaces = 0;
            pbar.update(0);
        end

        function enableParallel(pbar)
            pbar.parallel = true;
            pbar.trueColor = false;
            pbar.firstUpdate = true;
            pbar.fnamePrefix = tempname();
            try
                delete(sprintf('%s_*', pbar.fnamePrefix));
            catch
            end

%             pbar.objWorker = WorkerObjWrapper(@labindex, {});
        end

        function n = updateParallel(pbar, n)
%             id = pbar.objWorker.Value;
            t = getCurrentTask();
            if isempty(t)
               % not running in parallel mode
                % n = n;
                return;
            end
            id = t.ID;

            fname = sprintf('%s_%d', pbar.fnamePrefix, id);
            f = fopen(fname, 'a');
            fprintf(f, '.');
            fclose(f);

            if id == 1
                % allow all workers to do output
                d = dir([pbar.fnamePrefix '_*']);
                n = sum([d.bytes]);
%                 fprintf('Got %d bytes\n', n);
            else
                % non-primary worker, no output
                n = [];
            end
        end

        function cleanupParallel(pbar)
            if pbar.parallel
                delete(sprintf('%s_*', pbar.fnamePrefix));
            end
        end

        function increment(pbar, varargin)
            if nargin > 1 && isnumeric(varargin{1})
                by = varargin{1};
                varargin = varargin(2:end);
            else
                by = 1;
            end
            pbar.update(pbar.n+by, varargin{:});
        end

        function [ratio, progStr, progStrPercentOnly] = computeRatio(pbar)
           if pbar.N > 0
                numWidth = ceil(log10(pbar.N));
            else
                numWidth = 1;
           end
            n = pbar.n;

            if n < 0
                n = 0;
            end

            if isempty(pbar.N) || pbar.N == 1
                ratio = n;
                if ratio < 0
                    ratio = 0;
                end
                if ratio > 1
                    ratio = 1;
                end
                percentage = ratio * 100;
                progStr = sprintf('[ %5.1f%% ]', percentage);
                progStrPercentOnly = progStr;
            else
                ratio = (n-1)/pbar.N;
                if ratio < 0
                    ratio = 0;
                end
                if ratio > 1
                    ratio = 1;
                end
                percentage = ratio * 100;
                progStr = sprintf('%*d / %*d [ %5.1f%% ]', numWidth, n, numWidth, pbar.N, percentage);
                progStrPercentOnly = sprintf('[ %5.1f%% ]', percentage);
            end
        end

        function update(pbar, n, message, varargin)
            if feature('isdmlworker') && ~pbar.parallel
                return; % print nothing inside parfor loop if I'm not the main progress bar
            end

            if ~pbar.active
                return;
            end

            if nargin > 2
%                 newMessage = true;
                pbar.message = sprintf(message, varargin{:});
            else
%                 newMessage = false;
            end
            n = double(n);
            pbar.n = n; % store last update

            if pbar.parallel
                n = pbar.updateParallel(n);
                if isempty(n)
                    pbar.firstUpdate = false;
                    return;
                end
                pbar.n = n;
            end

            % don't run too often
            if isempty(pbar.lastCalled)
                pbar.lastCalled = clock;
            elseif etime(clock, pbar.lastCalled) < pbar.minInterval
                return;
            end

            pbar.lastCalled = clock;

            [ratio, progStr] = pbar.computeRatio();
            progLen = length(progStr);

            if length(pbar.message) + progLen + 3 > pbar.cols
                message = [pbar.message(1:(pbar.cols - progLen - 6)), '...'];
            else
                message = pbar.message;
            end
            message = char(message);

            gap = pbar.cols - 1 - (length(message)+1) - progLen + 1;
            spaces = repmat(' ', 1, gap);
            if pbar.usingTerminal || pbar.usingNotebook
                str = [message spaces progStr];
            else
                str = [message spaces blanks(numel(progStr))];
            end

            % separate into colored portion of bar and non-colored portion of bar
            ind = min(length(str), ceil(ratio*pbar.cols));
            preStr = str(1:ind);
            postStr = str(ind+1:end);
            
            % try using 24 color
            if pbar.trueColor
                newPreStr = '';
                for i = 1:numel(preStr)
                    %color = pbar.trueCmap(i, :);
                    cmapRow = mod(i-1 + round(ratio*pbar.cols), size(pbar.trueCmap, 1))+1;
                    color = round(pbar.trueCmap(cmapRow, :) * 255);
                    newPreStr = [newPreStr, sprintf('\x1b[48;2;%d;%d;%dm%s' , color, preStr(i))];
                end
                preStr = newPreStr;
            end

%             if isempty(getCurrentTask())
                try
                    DatabaseAnalysis.pauseOutputLog();
                catch
                end
%             end

            if pbar.usingTerminal || pbar.usingNotebook
                if pbar.parallel
                    if pbar.firstUpdate
                        fprintf('\b\r\033[1;44;37m%s\033[49;37m%s\033[0m\n', preStr, postStr);
                    else
                        fprintf('\033[2A\033[1;44;37m %s\033[49;37m%s\033[0m \n', preStr, postStr);
                    end
%                     fprintf('\033[1A;\033[1;44;37m %s %s\n', preStr, postStr);
%                     drawnow('update');
                else
                    if pbar.firstUpdate
                        fprintf(' '); % don't delete whole line on first update
                    end
                    if pbar.trueColor
                        fprintf('\b\r\033[1;44;37m%s\033[49;37m%s\033[0m ', preStr, postStr);
                    else
                        fprintf('\b\r\033[1;44;37m%s\033[49;37m%s\033[0m ', preStr, postStr);
                    end
                      drawnow update
%                     if pbar.trueColor
%                         fprintf('\b\r\033[1;44;37m%s\033[49;37m%s\033[0m ', preStr, postStr);
%                     else
%                         fprintf('\b\r\033[1;44;37m%s\033[49;37m%s\033[0m  ', preStr, postStr);
%                     end
                end
            else
                pbar.textprogressbar(ratio);

%                 % figure out number of boxes
%                 boxChar = char(9608);
%                 nTotal = pbar.cols - 4;
%                 idealBoxCount = ratio*(nTotal-numel(progStr)-2);
%                 nBoxes = floor(idealBoxCount);
%
%                 nBoxesLast = pbar.lastNBoxes;
%                 newBoxes = nBoxes - nBoxesLast;
%                 nSpaces = nTotal-nBoxes;
%                 boxes = repmat(boxChar, 1, newBoxes);
%
%                 fracLast = idealBoxCount - nBoxes;
%                 fractionalBox = ProgressBar.getFractionalBlockChar(fracLast);
%
%                 empty = blanks(nSpaces);
%                 empty((end-numel(progStr)+1):end) = progStr;
%
%                 % clear old lines
%                 if ~firstUpdate
%                     if newMessage
%                         backspaces = repmat('\b', 1, pbar.lastNSpaces + pbar.lastNBoxes + 1 + pbar.cols - 1);
%                     else
%                         % no need to update message, clear only the number
%                         % of boxes required
%                         backspaces = repmat('\b', 1, pbar.lastNSpaces + 1);
%                     end
%                     fprintf(backspaces);
%                 end
%
%                 pbar.lastNBoxes = nBoxes;
%                 pbar.lastNSpaces = nSpaces;
%
%
%                 if newMessage
%                     fprintf('%s%s\n', preStr, postStr);
%                 end
%
%                 fprintf('%s%c%s', boxes, fractionalBox, empty);

            end

%             if isempty(getCurrentTask())
                try
                    DatabaseAnalysis.resumeOutputLog();
                catch
                end
%             end

            pbar.firstUpdate = false;

            %str = sprintf('\b\r\033[1;44;37m %s\033[49;37m%s\033[0m ', preStr, postStr);
            %disp(str);

        end
        
        function pause_for_output(pbar)
            if feature('isdmlworker') && ~pbar.parallel
                return; % print nothing inside parfor loop if I'm not the main progress bar
            end

            if ~pbar.active
                return;
            end
            
            try
                DatabaseAnalysis.pauseOutputLog();
            catch
            end
            
            if pbar.usingTerminal || pbar.usingNotebook
                spaces = repmat(' ', 1, pbar.cols-1);
                if pbar.parallel
                    fprintf('\033[1A%s\033[0m\r', spaces);
                else
                    %spaces = repmat(' ', 1, pbar.cols-10);
                    %fprintf('\033[2K\033[0m\r');

                    % working on mac os
                    fprintf('\b\r%s\033[0m\r', spaces);
%                     fprintf('\033[1A\033[2K\r');
%                     pause(1);
                end
            else
%                 backspaces = repmat('\b', 1, pbar.lastNSpaces + pbar.lastNBoxes + 1 + pbar.cols - 1);
%                 fprintf(backspaces
                pbar.textprogressbar(1);
                fprintf('\n');
            end
            
            try
                DatabaseAnalysis.resumeOutputLog();
            catch
            end
            
            pbar.firstUpdate = true; % ensure the line won't be cleared on next update
        end
            

        function finish(pbar, message, varargin)
            % if message is provided (also in printf format), the message
            % will be displayed. Otherwise, the progress bar will disappear
            % and output will resume on the same line.

            %gap = pbar.cols - 1 - length(pbar.message);
            %spaces = repmat(' ' , 1, gap);
            %fprintf('\b\r%s%s\033[0m\n', pbar.message, spaces);

            if feature('isdmlworker') && ~pbar.parallel
                return; % print nothing inside parfor loop if I'm not the main progress bar
            end

            if ~pbar.active
                return;
            end

            try
                DatabaseAnalysis.pauseOutputLog();
            catch
            end

            if pbar.usingTerminal
                spaces = repmat(' ', 1, pbar.cols-1);
                if pbar.parallel
                    fprintf('\033[1A%s\033[0m\r', spaces);
                else
                    %spaces = repmat(' ', 1, pbar.cols-10);
                    %fprintf('\033[2K\033[0m\r');

                    % working on mac os
                    fprintf('\b\r%s\033[0m\r', spaces);
%                     fprintf('\033[1A\033[2K\r');
%                     pause(1);
                end
            elseif pbar.usingNotebook
                fprintf('\n');
%                 spaces = repmat(' ', 1, pbar.cols+1);
%                 fprintf('\b\r\033[0m%s ', spaces);
            else
%                 backspaces = repmat('\b', 1, pbar.lastNSpaces + pbar.lastNBoxes + 1 + pbar.cols - 1);
%                 fprintf(backspaces
                pbar.textprogressbar(1);
                fprintf('\n');
            end
            if nargin > 1
                pbar.message = sprintf(message, varargin{:});
                fprintf('%s\n', pbar.message);
            end

            %if pbar.parallel && exist(pbar.fname, 'file')
                %delete(pbar.fname);
            %end

            pbar.cleanupParallel();

%             if ~isempty(getCurrentTask())
                try
                    DatabaseAnalysis.resumeOutputLog();
                catch
                end
%             end
        end

        function textprogressbar(pbar, c)
            %
            % Original Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
            % Version: 1.0
            % Changes tracker:  29.06.2010  - First version
            %
            % Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/
            %
            % Modified by Dan O'Shea

            %% Initialization

            strPercentageLength = 9;   %   Length of percentage string (must be >5)
            strDotsMaximum      = 50;   %   The total number of dots in a progress bar

            if pbar.firstUpdate
                fprintf('%s : ', pbar.message);
                pbar.textprogressStrCR = -1;
            end

            c = round(c*100, 1);

            percentageOut = [num2str(c) '%%'];
            percentageOut = [repmat(' ',1,strPercentageLength-length(percentageOut)-1) percentageOut ' '];
            nDots = floor(c/100*strDotsMaximum);
            dotOut = ['[' repmat('_',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']   '];
            dotOut = ['|' repmat('█',1,nDots) repmat(' ',1,strDotsMaximum-nDots) '|   '];
            strOut = [percentageOut dotOut newline];

            % Print it on the screen
            if pbar.textprogressStrCR == -1
                % Don't do carriage return during first run
                fprintf(strOut);
            else
                % Do it during all the other runs
                fprintf([pbar.textprogressStrCR strOut]);
            end

            % Update carriage return
            pbar.textprogressStrCR = repmat('\b',1,length(strOut)-1);

        end

        function updateItermStatus(pbar)
            if ~pbar.usingItermStatus
                return;
            end
            if isempty(pbar.lastCalledItermStatus)
                pbar.lastCalledItermStatus = clock;
            elseif etime(clock, pbar.lastCalledItermStatus) < pbar.minIntervalItermStatus
                return;
            end

            [~, ~, progStr] = pbar.computeRatio();
            msg = [progStr, ' ', pbar.message];
            setItermStatus(msg);
        end
    end

    methods(Static)
        function demo(N, varargin)
            if nargin < 1
                N = 300;
            end
            if numel(varargin) == 0
                varargin = {'Running ProgressBarDemo with %d items', N};
            end

            pbar = ProgressBar(N, varargin{:});
            for i = 1:N
                pbar.update(i);
%                 if i == floor(N/2) && withInterruption
%                     fprintf('Random interruption!\n');
%                 end
                pause(0.01);
            end
            pbar.finish();
        end

        function demoNested()
            ni = 20;
            nj = 100;

            pi = ProgressBar(ni, 'Outer loop');
            for i = 1:ni
                pi.update(i);
                pj = ProgressBar(nj, 'Inner loop');
                for j = 1:nj
                    pj.update(j);
                    pause(0.001);
                end
                pj.finish();
            end
            pi.finish();
        end

        function demoParallel(N, varargin)
            if nargin < 1
                N = 200;
            end
            if numel(varargin) == 0
                varargin = {'Running ProgressBarDemo parallel with %d items', N};
            end

            pbar = ProgressBar(N, varargin{:});
            pbar.enableParallel();

            parfor i = 1:N
                pause(0.3*rand(1));
                pbar.update(i); %#ok<PFBNS>
            end
            pbar.finish();
        end

        function [rows, cols] = getTerminalSize()
            mode = getMatlabOutputMode();
            %usingTerminal = ismember(getMatlabOutputMode(), {'terminal', 'notebook'});

            % use sensible defaults
            rows = 24;
            cols = 80;

            if strcmp(mode, 'notebook')
                return;

            elseif (ismac || isunix) && strcmp(mode, 'terminal')
                % actual terminal: get terminal width using tput
                cmd = 'tput lines';
                [~, r] = unix(cmd);
                num = sscanf(r, '%d');
                if ~isempty(num)
                    rows = num(end);
                end

                cmd = 'tput cols';
                [~, r] = unix(cmd);
                num = sscanf(r, '%d');
                if ~isempty(num)
                    cols = num(end);
                end

            elseif strcmp(mode, 'desktop') %#ok<*PROP
                % matlab command window size
                try
                    jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                    cmdWin = jDesktop.getClient('Command Window');

                    jTextArea = cmdWin.getComponent(0).getViewport.getComponent(0);
                    height = jTextArea.getHeight();
                    width = jTextArea.getParent.getWidth();
                    font = jTextArea.getParent().getFont();
                    metrics = cmdWin.getFontMetrics(font);
                    charWidth = metrics.charWidth('A');
                    charHeight = metrics.getHeight();

                    rows = floor(height/charHeight);
                    cols = floor(width/charWidth);
                catch
                end
            end
        end

        function ch = getFractionalBlockChar(frac)
            if frac < 1/8
                ch = char(' ');
            elseif frac < 1
                ch = char(9614 - floor(frac / 0.125));
            end
        end


    end
end
