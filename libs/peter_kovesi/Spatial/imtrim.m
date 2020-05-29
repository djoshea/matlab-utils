% IMTRIM - removes a boundary of an image
%
% Usage:  trimmedim = imtrim(im, b)
%
% Arguments:     im - Image to be trimmed (greyscale or colour)
%                 b - Width of boundary to be removed
%
% Returns: trimmedim - Trimmed image of size rows-2*b x cols-2*b
%
% See also: IMPAD, IMSETBORDER

% Peter Kovesi
% www.peterkovesi.com/matlabfns/
% 
% June  2010

function tim = imtrim(im, b)

    if b == 0
        tim = im;
        return;
    end

    b = round(b);     % ensure integer
    [rows, cols, channels] = size(im);
    if rows <= 2*b || cols <= 2*b
        error('Amount to be trimmed is greater than image size');
    end
    tim = im(1+b:end-b, 1+b:end-b, :);