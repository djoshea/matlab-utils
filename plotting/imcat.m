function imcat(m)
    m = squeeze(m);
    
    % make large enough to see (min dimension should be 500 px)
    [r, c] = size(m);
    resizeBy = round(min(800 / r, 800 / c));
    if resizeBy > 1
        m = imresize(m, resizeBy, 'nearest');
    end
    
    % Now make an RGB image that matches display from IMAGESC:
    C = colormap;  % Get the figure's colormap.
    L = size(C,1);
    
    % Scale the matrix to the range of the map.
    maxM = nanmax(m(:));
    minM = nanmin(m(:));
    if maxM - minM < eps
        mc = ones(size(m));
    else
        mc = round(interp1(linspace(minM,maxM,L),1:L,m));
    end
    mc(isnan(mc)) = L+1; % specify nan's index into colormap
    C = cat(1, C, [0 0 0]); % make white the nan color
    mc = reshape(C(mc,:),[size(mc) 3]); % Make RGB image from scaled.
    
    f = tempname;
    imwrite(mc, f, 'png');
    imgcat(f);
end
    