% IMWRITEFLOATTIFF - Write single channel floating point data to a tiff file
%
% Usage: imwritefloattiff(im, fname)
%
% Arguments:    im - Single channel floating point image.
%            fname - Desired output fil.
%
% MATLAB's imwrite only seems to be able to write integer valued tiff images
% even though the format supports floating point data.  This function makes
% use of TIFF, MATLAB's gateway to the LibTIFF library routines to provide a
% basic floating point image writing function.
%
% See also: TIFF

% Peter Kovesi
% peterkovesi.com
%
% April 2018

% Reference:
% https://au.mathworks.com/matlabcentral/answers/7184-how-can-i-write-32-bit-floating-point-tifs-with-nans

function imwritefloattiff(im, fname)
    
    if ndims(im) == 3
        error('Can only write single band data');
    end
    
    type = class(im);
    if strcmp(type, 'double') 
        tagstruct.BitsPerSample = 64; 
    elseif strcmp(type, 'single') 
        tagstruct.BitsPerSample = 32;
    else
        error('Image is not floating point')
    end

    t = Tiff(fname, 'w'); 
    tagstruct.ImageLength = size(im, 1); 
    tagstruct.ImageWidth = size(im, 2); 
    tagstruct.Compression = Tiff.Compression.None; 
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP; 
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack; 
    tagstruct.SamplesPerPixel = 1; 
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
    t.setTag(tagstruct); 
    t.write(im); 
    t.close();