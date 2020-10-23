% this function is inspired by Peter Kovesi's applycoulourmap but can handle colormaps with breaks

% original credits for applycolourmap:
%
% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au

function rgbimg = applyColormapWithBreaks(img, map, rangeMat, breakAt)
% rgbim = applyColormapWithBreaks(im, map, rangeMat, breakAt)
% in is the input data, map is the N x 3 colormap
% rangeMat is a nIntervals x 2 set of value ranges of the form
%   [ interval1_low interval1_high; 
%     interval2_low interval2_high ]
% and breakAt is a nIntervals-1 set of row indices into map where the color map is broken.
% values inside the intervals will be linearly scaled to the colormap 1:breakAt(1)-1, breakAt(1):breakAt(2)-1, ...
%  - values below interval1_low will map to map(1, :) 
%  - values between interval i and i+1 map to the high color of the ith interval (i.e. breakAt(i) - 1)
%  - values above intervalN_high map to map(end, :)
    
    nM = size(map, 1);
    
    nIntervals = size(rangeMat, 1);
    assert(size(rangeMat, 2) == 2, 'rangeMat should be nIntervals x 2');
    assert(numel(breakAt) == nIntervals - 1, 'breakAt should have length nIntervals-1');
    
    [rows,cols] = size(img);
    
    rowimg = zeros(rows, cols);
    rowimg(img <= rangeMat(1, 1)) = 1; % low values map to map(1, :)
    
    for iI = 1:nIntervals
        % pick rows of map corresponding to this interval
        if iI == nIntervals
            rowlims = [breakAt(iI-1) nM];
        elseif iI == 1
            rowlims = [1 breakAt(1)];
        else
            rowlims = [breakAt(iI-1) breakAt(iI)];
        end
            
        % transform the image to [0 1] relative to this interval
        norm_img = (img - rangeMat(iI, 1)) / (rangeMat(iI, 2) - rangeMat(iI, 1));
        
        % within interval maps linearly
        rowimg_this = round(norm_img .* (rowlims(2) - rowlims(1)) + rowlims(1)); % compute cmap rows for values within this interval
        mask_in_interval = norm_img >= 0 & norm_img < 1;
        rowimg(mask_in_interval) = rowimg_this(mask_in_interval);
        
        % values above this interval map to the high color
        rowimg(norm_img >= 1) = rowlims(2);
    end
    
    rowimg(img >= rangeMat(end, 2)) = nM; % high values map to map(end, :)
    
    % rows*cols x 3 --
    mask = rowimg > 0;
    flat = nan(prod(size(rowimg)), 3);
    flat(mask, :) = map(rowimg(mask), :);
    rgbimg = reshape(flat, [rows cols 3]);
    
end
    