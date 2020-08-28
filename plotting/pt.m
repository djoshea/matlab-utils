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
otherDims = TensorUtils.otherDims(size(x), timeDim);
xr = TensorUtils.reshapeByConcatenatingDims(x, {timeDim, otherDims});
nTraces = size(xr, 2);

p = inputParser();
p.addParameter('colormap', [], @(x) isempty(x) || (~ischar(x) && ismatrix(x)));
p.addParameter('coloreval', [], @(x) isempty(x) || isvector(x));
p.addParameter('alpha', 0.8, @isscalar);
p.addParameter('stairs', false, @islogical);
p.addParameter('shuffleZ', false, @islogical); 
p.KeepUnmatched = true;
p.PartialMatching = false;
p.parse(args{:});

holding = ishold(gca);
if ~holding
    cla;
end

cmap = p.Results.colormap;
if isempty(cmap)
    cmap = TrialDataUtilities.Color.hslmap(nTraces);
end
if isa(cmap, 'function_handle')
    n = size(xr, 2);
    cmap = cmap(n);
end

if isempty(p.Results.coloreval)
    hold on;
    set(gca, 'ColorOrder', cmap, 'ColorOrderIndex', 1);
    h = plot(tvec, xr, p.Unmatched);
    
    for iH = 1:numel(h)
        h(iH).Color(4) = p.Results.alpha;
    end
    
    ax = gca;
    ax.TickDir = 'out';
    ax.ColorSpace.Colormap = cmap;
    ax.CLim = [1 numel(h)+eps];
else
    hold on;
    % plot lines according to their value in cmap
    coloreval = p.Results.coloreval;
    colorevalLims = [nanmin(coloreval(:)), nanmax(coloreval(:))];
    colors = TrialDataUtilities.Color.evalColorMapAt(cmap, coloreval, colorevalLims);
    
    if p.Results.stairs
        h = stairs(tvec, xr, p.Unmatched);
    else
        h = plot(tvec, xr, p.Unmatched);
    end
    
    
    for iH = 1:numel(h)
        if any(isnan(colors(iH, :)))
%             colors(iH, :) = [0 0 0];
            delete(h(iH));
        else
            h(iH).Color = cat(2, colors(iH, :), p.Results.alpha);
        end
    end
    
    ax = gca;
    ax.TickDir = 'out';
    ax.ColorSpace.Colormap = cmap;
    ax.CLim = colorevalLims;
%     hc = colorbar;
%     hc.TickDirection = 'out';
    
%     niceGrid;
    
end

if p.Results.shuffleZ
    mask = ismember(ax.Children, h);
    inds = find(mask);
    reorder = randsample(nnz(mask), nnz(mask));
    ax.Children(mask) = ax.Children(inds(reorder));
end

if ~holding
    hold off;
end