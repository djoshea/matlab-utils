% RECTINTERSECT - Returns true if rectangles intersect
%
% Usage:  intersect = rectintersect(r1, r2) 
%
% Arguments:  r1, r2 - The two rectangles to be tested where the
%                      rectangles are defined following the MATLAB 
%                      convention of [left bottom width height]
%
% See also: RECTANGLE

% Peter Kovesi
% peterkovesi.com
% January 2016

function intersect = rectintersect(r1, r2) 
    
    intersect = (r1(1) <= r2(1)+r2(3) && ...
                 r2(1) <= r1(1)+r1(3) && ...
                 r1(2) <= r2(2)+r2(4) && ...
                 r2(2) <= r1(2)+r1(4));

    
