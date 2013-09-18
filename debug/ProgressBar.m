classdef ProgressBar < handle
% Generates a progress bar which uses ANSI color codes to colorize output
% in a color terminal. The background color steadily advances along from 
% left to right beneath a custom message and progress percentage string.
%
% Usage:
%   pbar = ProgressBar('Message goes here', nThingsToProcess);
%   for i = 1:nThingsToProcess
%       pbar.update(i, [optional message update]);
%       ...
%   end
%   pbar.finish([optional final message]);
%         
% Demonstration:
%   ProgressBar.demo();
%   

    properties
        message
        N
        cols
        firstUpdate  
        timeStart
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

            fprintf('\b\r\033[1;44;37m %s\033[49;37m%s\033[0m ', preStr, postStr);
        end

        function finish(pbar, message, varargin)
            %gap = pbar.cols - 1 - length(pbar.message);
            %spaces = repmat(' ' , 1, gap);
            %fprintf('\b\r%s%s\033[0m\n', pbar.message, spaces);

            spaces = repmat(' ', 1, pbar.cols-1);
            fprintf('\b\r%s\033[0m\r', spaces);
            if nargin > 1
                pbar.message = sprintf(message, varargin{:});
                fprintf('%s\n', pbar.message);
            end
        end
    end

    methods(Static)
        function demo(withInterruption)
            if nargin == 0
                withInterruption = false;
            end
            N = 300;
            pbar = ProgressBar(N, 'Running ProgressBarDemo with %d items', N);
            for i = 1:N
                pbar.update(i);
                if i == floor(N/2) && withInterruption
                    fprintf('Random interruption!\n');
                end
                pause(0.01);
            end
            pbar.finish();
        end
    end

end
