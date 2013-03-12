function [cout,h]=contourspline(varargin)
%CONTOURSPLINE Contour Plot with Cubic Spline Fit Contours.
% CONTOURSPLINE(X,Y,Z,N) creates a contour plot having N contour levels
% from the matrix Z, treating the values in Z as heights above the X-Y
% plane. X and Y are either vectors defining the X- and Y-axes with
% length(X) = size(Z,2) and length(Y) = size(Z,1), or X and Y are matrices
% the same size as Z such as those produced by MESHGRID.
%
% CONTOURSPLINE(X,Y,Z,V) draws contours at the levels given in vector V.
% CONTOURSPLINE(X,Y,Z,[v v]) draws a single contour line at level v.
%
% Example:        [x,y,z]=peaks(14);      % sample data
%                 v=-3:1.2:6;             % contour levels to draw
%                 contour(x,y,z,v);       % standard contour
%                 hold on
%                 contourspline(x,y,z,v); % smoothed contours
%                 title('Original and Smoothed Contour')
%                 hold off
%
% If the function TRICONTOUR #11040 from the MATLAB File Exchange is
% available, then the following syntaxes also apply.
% See the following link for TRICONTOUR:
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=11040&objectType=FILE,
%
% CONTOURSPLINE(TRI,X,Y,Z,N) draws N contour lines treating the values
% in Z as heights above a plane. TRI,X,Y,and Z define a triangulation where
% the triangles are defined by the M-by-3 face matrix TRI, such as that
% returned by DELAUNAY. Each row of TRI contains indices into the X,Y, and
% Z vertex vectors to define a single triangular face. Contours are
% computed directly from the triangulation rather than interpolating back
% to a cartesian grid using GRIDDATA.
%
% CONTOURSPLINE(TRI,X,Y,Z,V) draws contour lines at the levels given in
% vector V.
% CONTOURSPLINE(TRI,X,Y,Z,[v v]) draws a single contour line at the level v.
%
% [C,H] = CONTOURSPLINE(...) returns contour matrix C as described in
% CONTOURC and a vector of handles H to the created patch objects.
% H can be used to set patch properties.
% CLABEL(C) or CLABEL(C,H) labels the contour levels.
%
% Beware: CONTOURSPLINE smooths contours, but does not magically change
% terrible data into pleasing data. For terrible data, smoothed contour
% lines may cross!
%
% See also CONTOUR, CONTOURC, CLABEL, MESHGRID

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2007-06-10

if nargin==4             % CONTOURSPLINE(X,Y,Z,N) or CONTOURSPLINE(X,Y,Z,V)
   
   [c,hd]=contour(varargin{:});
   
elseif nargin==5 % CONTOURSPLINE(TRI,X,Y,Z,N) or CONTOURSPLINE(TRI,X,Y,Z,V)
   
   if ~(exist('tricontour','file')==2)
      error('CONTOURSPLINE:rhs','Function TRICONTOUR is Not Available.')
   end
   [c,hd]=tricontour(varargin{:});
   
else
   error('CONTOURSPLINE:rhs','Four or FIve Input Argument Required.')
end
% have default contour plotted
xylim=get(gca,{'XLim' 'YLim'});
delete(hd) % eliminate original contours so they can be replaced

% move through c matrix, extracting data, finding spline, replotting
C=zeros(2,0);
h=[];
tol=1e-12;
col=1;   % index of column containing contour level and number of points
while col<size(c,2); % while less than total columns in c
   
   % extract contour data points
   zlevel=c(1,col);
   idx=col+1:col+c(2,col);
   xdata = c(1,idx);
   ydata = c(2,idx);
   isopen = abs(diff(c(1,idx([1 end]))))>tol || ...
            abs(diff(c(2,idx([1 end]))))>tol;
   col=col+c(2,col)+1;

   % smooth contour data by 2-D spline interpolation
   if ~isopen  % wrap data so closed curve is smooth at joint
      xdata=[xdata(end-1) xdata xdata(2)]; %#ok
      ydata=[ydata(end-1) ydata ydata(2)]; %#ok
   end

   % get path length to create independent variable
   t=[0 cumsum(hypot(diff(xdata),diff(ydata)))]; % independent variable

   % place interpolation points in between those in t    
   n=max(2,ceil(20/sqrt(length(t))));
   ti=repmat(t(1:end-1),n,1);
   d=repmat((0:n-1)'/n,1,length(xdata)-1);
   dt=repmat(diff(t),n,1);
   ti=ti+d.*dt;
   ti=[ti(:); t(end)]; % independent variable interpolation points

   % computer new contour points from spline fit
   xi=spline(t,xdata,ti);
   yi=spline(t,ydata,ti);
   if ~isopen   % take out redundant data if curve was closed
      xi=xi(n+1:end-n);
      yi=yi(n+1:end-n);
   else
      xi(end+1)=nan; %#ok don't close open contours
      yi(end+1)=nan; %#ok
   end
   k=length(xi);

   % create a patch containing the new contour
   if nargout<2                     % plot the contour
      patch('XData',xi,'YData',yi,'CData',repmat(zlevel,k,1),...
            'FaceColor','none','EdgeColor','flat','UserData',zlevel)
      C=horzcat(C,[zlevel xi';k yi']); % contour label data
   else                             % plot contour and create output

      h=[h;patch('XData',xi,'YData',yi,'CData',repmat(zlevel,k,1),...
         'FaceColor','none','EdgeColor','flat','UserData',zlevel)]; %#ok
      C=horzcat(C,[zlevel xi';k yi']); % contour label data
   end
end
set(gca,'XLim',xylim{1},'YLim',xylim{2},'box','on')
if nargout>0
   cout=C;
end


