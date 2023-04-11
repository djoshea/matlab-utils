function [h, hcbar] = pmatbin(m, varargin)

p = inputParser();
p.addParameter('colormap', [1 1 1; 0 0 0], @(x) true);
p.KeepUnmatched = true;
p.parse(varargin{:});

cmap = p.Results.colormap;
if isa(cmap, 'function_handle')
    cmap = cmap(2);
end

if ~islogical(m)
    m = m ~= 0;
end

[h, hcbar] = pmat(m, 'addColorbar', false, p.Unmatched);
colormap(cmap);
clim([0 1]);
