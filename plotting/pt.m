function h = pt(timeDim, varargin)
% pt(timeDim, dataTensor, ...)
% pt(timeDim, timeVec, dataTensor, ...)
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
cmap = TrialDataUtilities.Color.hslmap(nTraces);
set(gca, 'ColorOrder', cmap, 'ColorOrderIndex', 1);

h = plot(tvec, xr, args{:});