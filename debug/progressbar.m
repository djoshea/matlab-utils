classdef ProgressBar < handle
% Generates a progress bar which uses ANSI color codes to colorize output
% in a color terminal. The background color steadily advances along from 
% left to right beneath a custom message and progress percentage string.
%
% Usage:
%   pbar = ProgressBar('Message goes here', nThingsToProcess);
%   for i = 1:nThingsToProcess
%       pbar.update(i);
%       ...
%   end
%   pbar.finish();
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
        function pbar = ProgressBar(message, N)
            if nargin >= 1
                pbar.message = message;
            end
            if nargin >= 2
                pbar.N = N;
            else
                pbar.N = 1;
            end
            [~, pbar.cols] = getTerminalSize();
            pbar.firstUpdate = true;
            pbar.timeStart = now;
        end

        function update(pbar, n)
            if pbar.firstUpdate
                pbar.firstUpdate = false;
            end
            numWidth = ceil(log10(pbar.N));
            if isempty(pbar.N) || pbar.N == 1
                progStr = sprintf('[ %5.1f%% ]', n*100);
                progLen = 10;
            else
                progStr = sprintf('%*d / %*d [ %5.1f%% ]', numWidth, n, numWidth, pbar.N, n/pbar.N*100);
                progLen = numWidth*2 + 4 + 10;
            end
            gap = pbar.cols - 1 - length(pbar.message) - progLen;
            spaces = repmat(' ', 1, gap);
            str = [pbar.message spaces progStr]; 

            % separate into colored portion of bar and non-colored portion of bar
            ind = min(length(str), ceil(n/pbar.N*pbar.cols));
            preStr = str(1:ind);
            postStr = str(ind+1:end);

            fprintf('\b\r\033[42;30m%s\033[49;39m%s ', preStr, postStr);
        end

        function finish(pbar)
            gap = pbar.cols - 1 - length(pbar.message);
            spaces = repmat(' ' , 1, gap);
            fprintf('\b\r%s%s\n', pbar.message, spaces);
        end
    end

    methods(Static)
        function demo(withInterruption)
            if nargin == 0
                withInterruption = false;
            end
            N = 300;
            pbar = ProgressBar('Running ProgressBarDemo', N);
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
