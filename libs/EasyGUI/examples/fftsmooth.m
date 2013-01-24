% FFTSMOOTH  -         GUI with interactive image filtering 
%
%   FFTSMOOTH is an sample GUI that demonstrates spatial lowpass and
%   highpass filtering. The user can specify the image to use, the type of
%   the filter, and the filter cutoff. FFTSMOOTH uses a simple rectangular
%   window in the frequency space to do the filtering.
%
%   FFTSMOOTH also demonstrates how to have a standalone GUI panel
%   that controls a separate figure.

%   Copyright 2009 The MathWorks, Inc.

function fftsmooth

myGui = gui.autogui;
myGui.Name = 'FFTSMOOTH - Interactive image filtering';
myGui.Location = 'float';
myGui.Position = struct('x', 200, 'y', 100, 'width', 210, 'height', 166);

imageName = gui.textmenu('Choose image', {'clown', 'earth', 'flujet', 'mandrill', 'spine'});
cutoff = gui.slider('Cutoff frequency', [0 0.3]);
filterType = gui.textmenu('Filter type', {'Lowpass', 'Highpass'});

imageName.Value = 'mandrill';
cutoff.Value = 0.15;
filterType.Value = 'Lowpass';

myFigure1 = [];

while myGui.waitForInput(),    
    s = load(imageName.Value);
    isHighpass = strcmp(filterType.Value, 'Highpass');
    newX = imsmooth(s.X, cutoff.Value, isHighpass);
    
    if isempty(myFigure1) || ~ishandle(myFigure1)
        myFigure1 = figure('position', [200 300 650 300]);
        myAxes1 = subplot(1,2,1);
        myAxes2 = subplot(1,2,2);
    end
    
    axes(myAxes1);
    imagesc(s.X); axis equal; axis off;
    colormap(gray);

    axes(myAxes2);
    imagesc(newX); axis equal; axis off;
    colormap(gray);
end

if ishandle(myFigure1)
    delete(myFigure1);
end


%% ------------------------------------------
% imsmooth(x,frac,dohighpass)
%  use FFT2 to filter an image
%   x: the 2D image
%   frac: a value between 0 and 1.0 (where 1.0 is the Nyquist frequency). 
%         this sets the location of the cutoff; the same cutoff is
%         used for both dimensions.
function xout = imsmooth(x,frac,dohighpass)

fx = fftshift(fft2(x));

% create a mask
[xlen,ylen] = size(fx);
xm = round(xlen/2)+1;
ym = round(ylen/2)+1;
xboxlen = floor(xlen * frac/2);
yboxlen = floor(ylen * frac/2);

mask = zeros(size(fx));
mask(xm-xboxlen : xm+xboxlen, ym-yboxlen : ym+yboxlen) = 1;
if dohighpass,
    mask = 1 - mask;
end

% apply mask 
fx = mask .* fx;
xout = abs(ifft2(ifftshift(fx)));


