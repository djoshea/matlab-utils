classdef ProgressBar < handle
% Generates a progress bar which uses ANSI color codes to colorize output
% in a color terminal. The background color steadily advances along from 
% left to right beneath a custom message and progress percentage string.
%
% Parallel mode: this class works in spmd and parfor blocks, if
% .enableParallel is called BEFORE the spmd/parfor block. Only the thread
% with labindex==1 will output to the screen. 
%
% Usage:
%   pbar = ProgressBar('Message goes here', nThingsToProcess);
%   for i = 1:nThingsToProcess
%       pbar.update(i, [optional message update]);
%       ...
%   end
%   pbar.finish([optional final message]);
%
% Parallel usage:
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
%
%   parpool
%   ProgressBar.demoParallel();
%   

    properties(SetAccess=protected)
        message
        N
        cols
        firstUpdate  
        timeStart

        % enable for parallel for loops? see .enableParallel / disableParallel
        parallel = false;
        fnamePrefix
        
        objWorker
        
        nCompleteByWorker
    end

    methods
        function pbar = ProgressBar(N, message, varargin)
            if nargin > 1
                pbar.message = sprintf(message, varargin{:});
            else
                pbar.message = '';
            end
            
            if nargin >= 2
                pbar.N = N;
            else
                pbar.N = 1;
            end
            [~, pbar.cols] = getTerminalSize();
            pbar.firstUpdate = true;
            pbar.timeStart = now;
            pbar.update(0);
        end
        
        function enableParallel(pbar)
            pbar.parallel = true;
            pbar.fnamePrefix = tempname();
            try
                delete(sprintf('%s_*', pbar.fnamePrefix));
            catch
            end
            
            pbar.objWorker = WorkerObjWrapper(@labindex, {});
        end

        function n = updateParallel(pbar, n)           
            id = pbar.objWorker.Value;
            if ~isscalar(id)
                % not running in parallel mode
                n = n;
                return;
            end
            fname = sprintf('%s_%d', pbar.fnamePrefix, id);
            f = fopen(fname, 'a');
            fprintf(f, '.');
            fclose(f);
            
            if id == 1
                % i do all output
                d = dir([pbar.fnamePrefix '_*']);
                n = sum([d.bytes]); 
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
        
        function update(pbar, n, message, varargin)
            if nargin > 2
                pbar.message = sprintf(message, varargin{:});
            end
            
            if pbar.firstUpdate
                pbar.firstUpdate = false;
            end
            if pbar.N > 0
                numWidth = ceil(log10(pbar.N));
            else
                numWidth = 1;
            end

            if pbar.parallel
                n = pbar.updateParallel(n);
                if isempty(n)
                    return;
                end
            end
            
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
                %progLen = 10;
            else
                ratio = (n-1)/pbar.N;
                percentage = min(max(ratio*100, 0), 100);
                progStr = sprintf('%*d / %*d [ %5.1f%% ]', numWidth, n, numWidth, pbar.N, percentage);
                
                %progLen = numWidth*2 + 4 + 10;
            end
            
            progLen = length(progStr);
            
            if ratio < 0
                ratio = 0;
            end
            if ratio > 1
                ratio = 1;
            end
            
            if length(pbar.message) + progLen + 2 > pbar.cols
                message = [pbar.message(1:(pbar.cols - progLen - 6)), '...'];
            else
                message = pbar.message;
            end 
            
            gap = pbar.cols - 1 - (length(message)+1) - progLen;
            spaces = repmat(' ', 1, gap);
            str = [message spaces progStr]; 

            % separate into colored portion of bar and non-colored portion of bar
            ind = min(length(str), ceil(ratio*pbar.cols));
            preStr = str(1:ind);
            postStr = str(ind+1:end);

%            disp(n)
            if pbar.parallel
                fprintf('\033[1A\033[1;44;37m %s\033[49;37m%s\033[0m \n', preStr, postStr);
            else
                fprintf('\b\r\033[1;44;37m %s\033[49;37m%s\033[0m ', preStr, postStr);
            end
            %str = sprintf('\b\r\033[1;44;37m %s\033[49;37m%s\033[0m ', preStr, postStr);
            %disp(str);
            
        end

        function finish(pbar, message, varargin)
            % if message is provided (also in printf format), the message
            % will be displayed. Otherwise, the progress bar will disappear
            % and output will resume on the same line.
            
            %gap = pbar.cols - 1 - length(pbar.message);
            %spaces = repmat(' ' , 1, gap);
            %fprintf('\b\r%s%s\033[0m\n', pbar.message, spaces);

            spaces = repmat(' ', 1, pbar.cols-1);
            if pbar.parallel
                fprintf('\033[1A%s\033[0m\r', spaces);
            else
                fprintf('\b\r%s\033[0m\r', spaces);
            end
            if nargin > 1
                pbar.message = sprintf(message, varargin{:});
                fprintf('%s\n', pbar.message);
            end
            
            %if pbar.parallel && exist(pbar.fname, 'file')
                %delete(pbar.fname);
            %end
            
            pbar.cleanupParallel();
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
        
        function demoParallel(N, varargin)
            if nargin < 1
                N = 100;
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
    end



end
