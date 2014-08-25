function name = figName(varargin)
% figName([figh=gcf,] name) 
%   sets the name of a figure (in the title bar)
% name = figName([figh=gcf])
%   gets the name of a figure

    if nargin == 0
        % get name
        name = get(gcf, 'Name');
    elseif nargin == 1
        if isscalar(varargin{1});
            name = get(varargin{1}, 'Name');
        elseif ischar(varargin{1})
            set(gcf, 'Name', varargin{1}, 'NumberTitle', 'off');
        end
    else
        figh = varargin{1};
        name = varargin{2};
        assert(ischar(name), 'Usage: figName([figh], name)');
        assert(ishandle(figh), 'Usage: figName([figh], name)');
        
        set(figh, 'Name', name, 'NumberTitle', 'off');
    end
            
        