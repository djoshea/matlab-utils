function figSizeKeynote(scaleFactor)
    if nargin < 1
        scaleFactor = 1;
    end
    
    w = 922 / 72 * 2.54 / scaleFactor;
    h = 590 / 72 * 2.54 / scaleFactor;
    figSize([w h]);
end
