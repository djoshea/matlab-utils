function [traceCenters, hLines] = ptstack(timeDim, stackDims, varargin)
% ptstack(timeDim, dataTensor, ...)
% ptstack(timeDim, timeVec, dataTensor, ...)
%
% parameters:
%   colormap
%   other parameters will be passed thru to plot(...)
%
% uses plotStackedTraces to quickly plot a tensor. timeDim is the time
% dimension, stackDims are the dimensions to stack vertically, remaining
% dimensions will be superimposed in the same plots

narg = numel(varargin);
if isvector(varargin{1}) && narg > 1 && isnumeric(varargin{2})
    x = varargin{2};
    tvec = makecol(varargin{1});
    args = varargin(3:end);
else
    x = varargin{1};
    tvec = (0:size(x, timeDim)-1)';
    args = varargin(2:end);
end

stackDims = makecol(stackDims);

sz = size(x);
nStack = prod(sz(stackDims));
if nStack > 50
    error('Refusing to stack more than 50 traces');
end

superimposeDims = TensorUtils.otherDims(size(x), [timeDim; stackDims]);

nSuperimpose = prod(sz(superimposeDims));
if nSuperimpose > 50
    error('Refusing to superimpose more than 50 traces');
end

% xr will be T x nStack x nSuperimpose
xr = TensorUtils.reshapeByConcatenatingDims(x, {timeDim, stackDims, superimposeDims});
p = inputParser();
%p.addParameter('colormap', TrialDataUtilities.Color.hslmap(nSuperimpose, 'fracHueSpan', 0.9), @(x) ~ischar(x) && ismatrix(x));
p.addParameter('namesAlongDims', {}, @iscell);
%p.addParameter('alpha', 1, @isscalar);
p.KeepUnmatched = true;
p.PartialMatching = false;
p.parse(args{:});

if ~isempty(p.Results.namesAlongDims)
    namesAlongDims = p.Results.namesAlongDims;
    if numel(namesAlongDims) ~= ndims(x)
        error('namesAlongDims must be cell with lengths ndims (including time dim)');
    end
    
    namesStack = namesAlongDims(stackDims);
    namesSuperimpose = namesAlongDims(otherDims);
    
    labelsStack = TensorUtils.flatten(TensorUtils.buildCombinatorialStringTensorFromLists(namesStack));
    labelsSuperimpose = TensorUtils.flatten(TensorUtils.buildCombinatorialStringTensorFromLists(namesSuperimpose));
else
    labelsStack = {};
    labelsSuperimpose = {};
end   

clf;
[traceCenters, hLines] = TrialDataUtilities.Plotting.plotStackedTraces(tvec, xr, ...
    'labels', labelsStack, 'labelsLinesWithinEachTrace', labelsSuperimpose, p.Unmatched);

% set(gca, 'ColorOrder', cmap, 'ColorOrderIndex', 1);
% hold on;
% h = plot(tvec, xr, p.Unmatched);
% for iH = 1:numel(h)
%     h(iH).Color(4) = p.Results.alpha;
% end
% hold off;