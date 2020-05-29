% SYNCSHOW - Show multiple images/figures with axes linked for pan and zoom
%
% Usage: syncshow(im1, im2, ...)
%        syncshow(fig1, fig2, ...)
%
% Arguments: 
%     im1/fig1  ...  A list of images to display with syncronised pan and
%                    zoom, or a list of existing figures to link so that pan
%                    and zoom is synchronised.
%
% Images should have the same size for predictable results
%
% See also: TOGGLEFIGS, SHOW

% Peter Kovesi
% peterkovesi.com
% June 2018

function syncshow(varargin)

for n = 1:length(varargin)
    try
        if prod(size(varargin{n})) > 1 % Assume it is an image
            h = show(varargin{n});
            ax(n) = get(h, 'CurrentAxes');
        elseif prod(size(varargin{n})) == 1 % Assume it is a figure number
            ax(n) = get(varargin{n}, 'CurrentAxes');
        end
    
    catch
        fprintf(['Argument %d does not seem to be an image or figure ' ...
                 'number\n'], n)
    end
end

linkaxes(ax, 'xy')

