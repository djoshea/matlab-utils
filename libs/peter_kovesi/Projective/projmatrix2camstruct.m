% PROJMATRIX2CAMSTRUCT - Projection matrix to camera structure
%
% Function takes a projection matrix and returns its equivalent camera
% structure.
%
% Usage: C = projmatrix2camstruct(P, rows, cols)
%
% Argument: P - 3x4 camera projection matrix that maps homogeneous 3D world 
%               coordinates to homogeneous image coordinates.
%   rows,cols - Optional specification of number of rows and columns in the
%               camera image.  This can get used later in functions such as
%               CAMERAPROJECT to determine if projected points are within
%               image bounds.
%
% Returns:  C - Camera structure.
%
% See also: CAMSTRUCT2PROJMATRIX, CAMSTRUCT, CAMERAPROJECT

% Copyright (c) Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% PK April 2015
%    August 2015  Renaming of radial and tangential distortion parameters

function C = projmatrix2camstruct(P, rows, cols)
    
    if ~exist('rows', 'var') || ~exist('cols', 'var') 
        rows = 0;
        cols = 0;
    end
    
    [K, Rc_w, Pc, pp, pv] = decomposecamera(P);
    
    C = struct('fx', K(1,1), 'fy', K(2,2), ...
               'skew', K(1,2), ...
               'ppx', pp(1), 'ppy', pp(2), ...
               'k1', 0, 'k2', 0, 'k3', 0, 'p1', 0, 'p2', 0, ...
               'rows', rows, 'cols', cols, ...
               'P', Pc(:), 'Rc_w', Rc_w);
    

    
    
    
