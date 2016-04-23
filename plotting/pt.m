function [h, cmap] = pt(timeDim, varargin)
% pt(timeDim, dataTensor, ...)
% pt(timeDim, timeVec, dataTensor, ...)
%
% parameters:
%   colormap
%   other parameters will be passed thru to plot(...)
%
% like plot except treats timeDim as the timeDimension and moves everything
% else to the second dim to be plotted on top of it


narg = numel(varargin);
if isvector(varargin{1}) && narg > 1 && isnumeric(varargin{2})
    x = varargin{2};
    tvec = makecol(varargin{1});
    args = varargin(3:end);
else
    x = varargin{1};
    tvec = (1:size(x, timeDim))';
    args = varargin(2:end);
end

% other dims taken care of automatically
otherDims = TensorUtils.otherDims(x, timeDim);
xr = TensorUtils.reshapeByConcatenatingDims(x, {timeDim, otherDims});
nTraces = size(xr, 2);

p = inputParser();
p.addParameter('colormap', TrialDataUtilities.Color.hslmap(nTraces, 'fracHueSpan', 0.9), @(x) ~ischar(x) && ismatrix(x));
p.addParameter('alpha', 1, @isscalar);
p.KeepUnmatched = true;
p.PartialMatching = false;
p.parse(args{:});

cmap = p.Results.colormap;
set(gca, 'ColorOrder', cmap, 'ColorOrderIndex', 1);
hold on;
h = plot(tvec, xr, p.Unmatched);
for iH = 1:numel(h)
    h(iH).Color(4) = p.Results.alpha;
end
hold off;