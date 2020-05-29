% TOGGLEFIGS  Convenient switching between figures to aid comparison
%
% Usage 1:   togglefigs
%
% Use arrow keys to index through figures that are currently being displayed, or
% enter single digit figure numbers to select figures directly.
% Hit ''x'' to exit.
%
% Usage 2:   togglefigs(figs)
% Argument:  figs - figure numbers entered as an array or individually
%                   separated by commas, to toggle.  Hitting 
%                   any key will cycle to next figure.
%
% The axes of the images are linked so that pan and zoom are synchronised on all
% images.
%
% For example, if you have 3 figures you wish to compare use:
% >> togglefigs(1, 2, 3)  or
% >> togglefigs(1:3)
%
% See also: SYNCSHOW

% Peter Kovesi
% peterkovesi.com
% March 2010
% May   2011 Modified to automatically find all figures and allow you to
%            use arrow keys and single digit figure numbers.
% Feb   2014 Automatically align the positions of the specified figures.
% June  2018 Axes of all images are linked so that pan and zoom are
%            synchronised.

% To do: Needs a rewrite to get rid of all the the repeated code.

function togglefigs(varargin)
    
    figs = getfigs(varargin(:));
    
    if isempty(figs)
        % No figure numbers were entered, find what figure windows are open
        figs = sort(get(0,'Children'));
        if isempty(figs)
            fprintf('No figure windows to display\n');
            return
        else
            fprintf('Use arrow keys to index through figures, or enter single\n');
            fprintf('digit figure numbers to select figures directly, hit ''X'' to exit\n');
        end

        % Identify axes for each figure and link them so that zoom and pan on all images
        % are synchronised.
        for n = 1:length(figs)
            ax(n) = get(figs(n), 'CurrentAxes');
        end
        linkaxes(ax, 'xy');
        
        
        % Set figures so that they all have the same position
        posn = get(figs(1),'Position');  
        for n = 2:length(figs)
            set(figs(n),'Position',posn);
        end        
        
        figIndex = 1;
        figure(figs(figIndex));
        while 1
            pause;
            ch = get(gcf,'CurrentCharacter'); 
            val = uint8(ch);
            numeral = val - uint8('0');
            
            if lower(ch)=='x'
                return
            elseif ismember(numeral,figs)
                [tf, figIndex] = ismember(numeral, figs);
            elseif val == 29 || val == 31
                figIndex = figIndex+1; if figIndex > length(figs), figIndex = 1; end
            elseif val == 28 || val == 30
                figIndex = figIndex-1; if figIndex < 1, figIndex = length(figs); end
            end
            figure(figs(figIndex));
        end

    else  % Cycle through the list of figure numbers supplied in the argument list
        fprintf('Hit any key to toggle figures, ''X'' to exit\n'); 
        
        % Identify axes for each figure and link them so that zoom and pan on all images
        % are synchronised.
        for n = 1:length(figs)
            ax(n) = get(figs(n), 'CurrentAxes');
        end
        linkaxes(ax, 'xy');        
        
        % Set figures so that they all have the same position
        posn = get(figs(1),'Position');  
        for n = 2:length(figs)
            set(figs(n),'Position',posn);
        end
        
        while 1
            for n = 1:length(figs)
                figure(figs(n));
                
                pause;
                ch = get(gcf,'CurrentCharacter'); 
                if lower(ch)=='x'
                    return
                end
            end
        end
    end
    
%------------------------------------------
function figs = getfigs(arg)
    
    figs = [];
    for n = 1:length(arg)
         figs = [figs arg{n}];
    end
    