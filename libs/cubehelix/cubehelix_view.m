function cubehelix_view(N,start,rots,sat,gamma,yrange,domain)
% Create an interactive figure for Cubehelix colormap parameter selection. With demo!
%
% (c) 2015 Stephen Cobeldick
%
% View any of Dave Green's Cubehelix colorschemes in a figure. Two colorbars
% show both the colorscheme and the grayscale equivalent. A button switches
% between 3D RGB-cube and 2D RGB-lineplot representations of the RGB values.
%
% Nine sliders allow real-time interactive adjustment of all of the Cubehelix
% parameter values, which are also displayed as text. The parameters can also
% be set/reset by calling the function with these values as input arguments:
% this function has exactly the same input arguments as "cubehelix" itself.
%
% Warnings are displayed in the figure if any RGB values are clipped, or if
% the grayscale equivalent is not strictly monotonic increasing/decreasing.
%
% Clicking the 'Demo' button provides an endless display of randomly
% generated Cubehelix color schemes. Click it again to stop this display.
%
% Syntax:
%  cubehelix_view
%  cubehelix_view(N)
%  cubehelix_view(N,start,rots,sat,gamma)
%  cubehelix_view(N,start,rots,sat,gamma,yrange)
%  cubehelix_view(N,start,rots,sat,gamma,yrange,domain)
%  cubehelix_view(N,[start,rots,sat,gamma],...)
%  cubehelix_view([],...)
%
% Cubehelix is defined here: http://astron-soc.in/bulletin/11June/289392011.pdf
% For more information and examples: http://www.mrao.cam.ac.uk/~dag/CUBEHELIX/
%
% See also CUBEHELIX BREWERMAP RGBPLOT COLORMAP COLORMAPEDITOR COLORBAR UICONTROL ADDLISTENER
%
% ### Input Arguments ###
%
% Inputs (*=default):
%  N     = NumericScalar, an integer to define the colormap length, N~=0.
%        = *[], the length is determined internally to suit the colormap.
%  start = NumericScalar, *0.5,  the helix's start color, with R=1, G=2, B=3 etc. (modulus 3).
%  rots  = NumericScalar, *-1.5, the number of R->G->B rotations over the scheme length.
%  sat   = NumericScalar, *1,    controls how saturated the colors are.
%  gamma = NumericScalar, *1,    can be used to emphasize low or high intensity values.
%  yrange = NumericVector, *[0,1], range of brightness levels of the colormap's endnodes. Size 1x2.
%  domain = NumericVector, *[0,1], domain of the cubehelix calculation (endnode positions). Size 1x2.
%
% cubehelix_view(N, start, rots, sat, gamma, yrange, domain)
% OR
% cubehelix_view(N, [start,rots,sat,gamma], yrange, domain)

% ### Input Wrangling ###
%
if nargin==0 || isnumeric(N)&&isempty(N)
    N = 200;
else
    assert(isnumeric(N)&&isscalar(N),'Input <N> must be a scalar numeric.')
    assert(isreal(N)&&fix(N)==N&&N~=0,'Input <N> must be non-zero real integer: %g+%gi',N,imag(N))
    N = double(N);
end
%
%     [sta; rots; sat; gam; yrng; domn]
dfa = [0.5; -1.5;   1;   1; 0; 1; 0; 1];
%
stp = '%s input can be a vector of the four Cubehelix parameters.';
str = '%s input can be a vector of the endnode brightness levels (range).';
std = '%s input can be a vector of the endnode relative positions (domain).';
%
switch nargin
    case {0,1}
        chvUpDt(N, dfa(1:8), false);
    case 2
        start = chvChk(4,start,stp,'Second');
        chvUpDt(N, [start;dfa(5:8)], false);
    case 3
        start = chvChk(4,start,stp,'Second');
        rots  = chvChk(2,rots, str,'Third');
        chvUpDt(N, [start;rots;dfa(7:8)], false);
    case 4
        start = chvChk(4,start,stp,'Second');
        rots  = chvChk(2,rots, str,'Third');
        sat   = chvChk(2,sat,  std,'Fourth');
        chvUpDt(N, [start;rots;sat], false);
    case 5
        chvUpDt(N, [chvC2V(start,rots,sat,gamma);dfa(5:8)], false);
    case 6
        yrange = chvChk(2,yrange,str,'Sixth');
        chvUpDt(N, [chvC2V(start,rots,sat,gamma);yrange;dfa(7:8)], false);
    case 7
        yrange = chvChk(2,yrange,str,'Sixth');
        domain = chvChk(2,domain,std,'Seventh');
        chvUpDt(N, [chvC2V(start,rots,sat,gamma);yrange;domain], false);
    otherwise
        error('Wrong number of inputs. Enter parameters individually or in a vector.')
end
%
end
%----------------------------------------------------------------------END:cubehelix_view
function vals = chvC2V(varargin)
% Check that all of the input variables are real scalar numerics.
str = 'Input Cubehelix parameters must be %s values.';
assert(all(cellfun(@isnumeric,varargin)),str,'numeric')
assert(all(cellfun(@isscalar,varargin)),str,'scalar')
assert(all(cellfun(@isfinite,varargin)),str,'finite')
assert(all(cellfun(@isreal,varargin)),str,'real')
vals = cellfun(@double,varargin(:));
end
%----------------------------------------------------------------------END:chvC2V
function x = chvChk(n,x,msg,ord)
% Check that the input variable <x> is real numeric vector with <n> elements.
assert(isnumeric(x)&&isreal(x)&&all(isfinite(x))&&isvector(x)&&numel(x)==n,msg,ord)
x = double(x(:));
end
%----------------------------------------------------------------------END:chvChk
function [N,vals] = chvUpDt(N,vals,isd)
% Draw a new figure or update an existing figure. Callback for sliders & demo.
%
persistent ln2D pt3D imgA imgI uicB uicS txtS txtW prev Np
%
% LHS and RHS slider bounds/limits, and slider step sizes:
lbd = [  1, 0,-3, 0, 0, 0, 0, 0, 0].';
rbd = [200, 3, 3, 3, 3, 1, 1, 1, 1].';
stp = [ 10, 1, 1, 1, 1, 1, 1, 1, 1;...
       100, 5, 5, 5, 5, 2, 2, 2, 2].'/10;
%
switch nargin
    case 0 % Demo initialize
        N = Np;
        vals = prev;
    case 1 % Slider callback
        if get(uicB(2),'Value')
            return
        end
        vals = prev;
        if N>1
            vals(N-1) = get(uicS(N),'Value');
            N = Np;
        else
            N = round(get(uicS(1),'Value'));
        end
        %
    case 3 % Function call OR Demo update
        if isempty(ln2D) || ~all(ishghandle(ln2D))
            if isd, return, end
            % Create a new figure:
            [ln2D,pt3D,imgA,imgI,uicB,uicS,txtS,txtW] = chvPlot(lbd,rbd,stp,[N;vals]);
        else
            % Update slider positions:
            set(uicS, {'Value'},num2cell(max(lbd,min(rbd,[N;vals]))));
        end
        %
    otherwise
        error('This really should not happen... I don''t know what to do now :(')
end
%
Np = N;
prev = vals;
%
% Update parameter value text:
set(txtS(1), 'String',sprintf('%.0f',N));
set(txtS(2:end), {'String'}, sprintfc('%.2f',vals));
%
% Get Cubehelix colormap:
[map,lo,hi]  = cubehelix(N, vals(1:4), vals(5:6), vals(7:8));
mag = sum(map*[0.298936;0.587043;0.114021],2);
%
% Update colorbar values:
set(imgA, 'YLim', [0,abs(N)+(N==0)]+0.5);
set(imgI(1), 'CData',reshape(map,[],1,3))
set(imgI(2), 'CData',repmat(mag,[1,1,3]))
%
% Update 2D line / 3D patch values:
if get(uicB(1),'Value')
    set(ln2D, 'XData',linspace(0,1,abs(N)));
    set(ln2D, {'YData'},num2cell([map,mag],1).');
else
    set(pt3D, 'XData',map(:,1), 'YData',map(:,2), 'ZData',map(:,3), 'FaceVertexCData',map)
end
%
% Update warning text:
mad = diff(mag);
str = {'Not Monotonic';'Clipped'};
set(txtW,'String',str([any(mad<=0)&&any(0<=mad);any(lo(:))||any(hi(:))]));
%
end
%----------------------------------------------------------------------END:chvUpDt
function [ln2D,pt3D,imgA,imgI,uicB,uicS,txtS,txtW] = chvPlot(lbd,rbd,stp,vals)
% Draw a new figure with RGBplot axes, ColorBar axes, and uicontrol sliders.
%
% Parameter names:
names = {'N';'start';'rotations';'sat';'gamma';'yrange(1)';'yrange(2)';'domain(1)';'domain(2)'};
M = numel(names);
gap = 0.01;
hgt = 0.60;
lft = 0.19;
rgt = 0.24;
wdt = 1-lft-rgt-2*gap;
brh = (1-gap-hgt)/M - gap;
%
figH = figure('HandleVisibility','callback', 'NumberTitle','off',...
    'Name','Cubehelix Interactive Parameter Selector', 'Color','white');
%
% Add 2D lineplot:
ax2D = axes('Parent',figH, 'Position',[gap, 1-hgt+gap, lft+wdt, hgt-2*gap],...
    'ColorOrder',[1,0,0; 0,1,0; 0,0,1; 0.6,0.6,0.6], 'HitTest','off',...
    'Visible','off', 'XLim',[0,1], 'YLim',[0,1], 'XTick',[], 'YTick',[]);
ln2D = line([0,0,0,0;1,1,1,1],[0,0,0,0;1,1,1,1], 'Parent',ax2D, 'Visible','off');
%
% Add 3D scatterplot:
ax3D = axes('Parent',figH, 'OuterPosition',[0, 1-hgt, lft+wdt+2*gap, hgt],...
    'Visible','on', 'XLim',[0,1], 'YLim',[0,1], 'ZLim',[0,1], 'HitTest','on');
pt3D = patch('Parent',ax3D, 'XData',[0;1], 'YData',[0;1], 'ZData',[0;1],...
    'Visible','on', 'LineStyle','none', 'FaceColor','none', 'MarkerEdgeColor','none',...
    'Marker','o', 'MarkerFaceColor','flat', 'MarkerSize',10, 'FaceVertexCData',[1,1,0;1,0,1]);
view(ax3D,3);
grid(ax3D,'on')
xlabel(ax3D,'Red')
ylabel(ax3D,'Green')
zlabel(ax3D,'Blue')
%
% Add warning text:
txtW = text('Parent',ax2D, 'Units','normalized', 'Position',[0,1],...
    'HorizontalAlignment','left', 'VerticalAlignment','top', 'Color','r');
%
% Add demo button:
uicB(2) = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
    'Position',[wdt+lft/2+gap,1-hgt+gap,lft/2,1.2*brh], 'String','Demo',...
    'Max',1, 'Min',0, 'Callback',@chvDemo);
%
% Add 2D/3D button:
uicB(1) = uicontrol(figH, 'Style','togglebutton', 'Units','normalized',...
    'Position',[wdt+gap,1-hgt+gap,lft/2,1.2*brh], 'String','2D / 3D',...
    'Max',1, 'Min',0, 'Callback',@(h,~)chv2D3D(ax2D,ln2D,ax3D,pt3D,h));
%
vals = max(lbd,min(rbd,vals));
temp(M) = 0;
txtS(M) = 0;
uicS(M) = 0;
for m = 1:M
    % Add parameter sliders:
    Y = gap+(M-m)*(brh+gap);
    uicS(m) = uicontrol(figH,'Style','slider', 'Units','normalized',...
        'Position',[lft+gap,Y,wdt,brh], 'Min',lbd(m), 'Max',rbd(m),...
        'SliderStep',stp(m,:)/(rbd(m)-lbd(m)), 'Value',vals(m));
    addlistener(uicS(m), 'Value', 'PostSet',@(a,b)chvUpDt(m));
    % Add text to show slider parameter values:
    temp(m) = uicontrol(figH,'Style','text', 'Units','normalized',...
        'Position',[gap,Y,lft/2,brh], 'String',names{m});
    txtS(m) = uicontrol(figH,'Style','text', 'Units','normalized',...
        'Position',[gap+lft/2,Y,lft/2,brh], 'String','X');
end
%
% Add colorbars:
C = reshape([1,1,1],1,[],3);
imgA(1) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
    'Position',[1-rgt/1,gap,rgt/2-gap,1-2*gap], 'YLim',[0.5,1.5], 'HitTest','off');
imgA(2) = axes('Parent',figH, 'Visible','off', 'Units','normalized',...
    'Position',[1-rgt/2,gap,rgt/2-gap,1-2*gap], 'YLim',[0.5,1.5], 'HitTest','off');
imgI(1) = image('Parent',imgA(1), 'CData',C);
imgI(2) = image('Parent',imgA(2), 'CData',C);
%
end
%----------------------------------------------------------------------END:chvPlot
function chv2D3D(ax2D,ln2D,ax3D,pt3D,tgh)
%
if get(tgh,'Value')% 2D
    set(ax3D, 'HitTest','off', 'Visible','off')
    set(ax2D, 'HitTest','on')
    set(pt3D, 'Visible','off')
    set(ln2D, 'Visible','on')
else % 3D
    set(ax2D, 'HitTest','off')
    set(ax3D, 'HitTest','on', 'Visible','on')
    set(ln2D, 'Visible','off')
    set(pt3D, 'Visible','on')
end
chvUpDt;
%
end
%----------------------------------------------------------------------END:chv2D3D
function chvDemo(tgh,~)
% While the toggle button is depressed run a loop showing random Cubehelix schemes.
%
% Step size between updates:
step = 0.03;
%
% Initial values:
[N,vals] = chvUpDt();
G = N; goal = vals;
%
% Functions to randomly find new values:
randfn(7:8) = {@()rand(1,1).^42,@()1-rand(1,1).^42};
randfn(3:4) = {@()sqrt(-log(rand(1,1))*2)};
randfn(1:2) = {@()3*rand(1,1),@()randn(1,1)};
randfn(5:6) = randfn(7:8);
%
% While the toggle button is down, step values:
while ishghandle(tgh)&&get(tgh,'Value')
    %
    % vals:
    isnw = vals==goal; % create new goal
    goal(isnw) = round(100*cellfun(@(fn)fn(),randfn(isnw)))/100;
    %
    isnx = abs(goal-vals)<=step; % close to goal
    vals(isnx) = goal(isnx);
    %
    isgo = ~(isnw|isnx); % on its way to goal
    vals(isgo) = vals(isgo) + step*sign(goal(isgo)-vals(isgo));
    %
    % N:
    if N==G % new goal
        G = round(1+199*rand(1,1));
    elseif abs(N-G)<=1 % close to goal
        N = G;
    else % on its way to goal
        N = N + sign(G-N);
    end
    %
    % Update figure:
    [N,vals] = chvUpDt(round(N),vals,true);
    %
    % Frame-rate faster/slower:
    pause(0.07);
end
%
end
%----------------------------------------------------------------------END:chvDemo