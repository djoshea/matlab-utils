function H=tcolor(x,y,c,varargin)
% for use like pcolor but with c as a true color matrix (uses texturemap for speed)...
%
% H=tcolor(x,y,c[,method])
%
% valid methods are: 'corners','normal','triangles'
%
% The normal method is texture mapping unto the plane given by x and y 
% (which may be distorted arbitrarily)
%
% The 'corners' method is the fastest way to draw. However it requires that
% the area is non-distorted... E.g. that the box defined by the corners
% defines the area.
%
% The slowest method is 'triangles'... (sort of like pcolor). But shading
% interp works with it.
%
% c=imread('C:\Projects\My Pictures\peppermint_girl.jpg');
% [x,y] = meshgrid(1:size(im,2),1:size(im,1));
% x=x+y/10; %skew the image
% H=tcolor(x,y,c,'corners')
%
% Aslak Grinsted - July 2003

p = inputParser();
p.addParameter('method', "normal", @isstringlike);
p.KeepUnmatched = true;
p.parse(varargin{:});

cax = newplot;
hold_state = ishold;
lims = [min(min(x)) max(max(x)) min(min(y)) max(max(y))];
method=string(p.Results.method);
triangles=0;

switch method
    case "normal"
    case "corners"
        if length(size(x))==2
            x=x([1 end],[1 end]);
            y=y([1 end],[1 end]);
        else
            x=x([1 1;end end]);
            y=y([1 end;1 end]);    
        end
    case "triangles"
        triangles=1;
    otherwise
        error('Unknown method?')
        return
end
    
if length(size(x))==1
    [x,y]=meshgrid(x,y);
end
if triangles
    H=patch(surf2patch(x,y,zeros(size(x)),im2double(c),'triangles'),'edgecolor','none','facecolor','flat', p.Unmatched);
else
    H=surface(x,y,zeros(size(x)),c,'EdgeColor','none','FaceColor','texturemap', p.Unmatched);
end
if ~hold_state
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    axis(lims);
end
if (nargout==0) 
    clear H;
end

end
