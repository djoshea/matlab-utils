function [h, hcbar] = pmatbal(m, varargin)

p = inputParser();
p.addParameter('colormap', 'balance', @(x) ischar(x) || ismatrix(x) || isa(x, 'function_handle'));
p.KeepUnmatched = true;
p.parse(varargin{:});

cmap = p.Results.colormap;
if isa(cmap, 'function_handle')
    cmap = cmap(256);
elseif ischar(cmap)
    switch cmap
        case 'balance'
            cmap = TrialDataUtilities.Color.cmocean('balance');
        otherwise
            cmap = TrialDataUtilities.Color.cbrewer('div', cmap, 256);
    end
end

% visualize a matrix using pcolor

[h, hcbar] = pmat(m, p.Unmatched);
colormap(cmap);
L = max(abs(m(:)));
caxis([-L L]);
