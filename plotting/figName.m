function figName(varargin)
% figname(figh, name)
% figname(name) - uses gcf
% Sets the name of a figure in the title bar

if(nargin == 2)
    figh = varargin{1};
    name = varargin{2};
elseif(nargin == 1)
    figh = gcf;
    name = varargin{1};
else
    error('Requires 1 or 2 arguments: [figh=gcf], name');
end

set(figh, 'NumberTitle', 'off', 'Name', name);
