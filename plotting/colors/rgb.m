function [RGB] = rgb(ColorNames,varargin)
% RGB returns the RGB triple of the 949 most common names for colors,
% according to the results of the XKCD survey described here: 
% http://blog.xkcd.com/2010/05/03/color-survey-results/ 
% 
% To see a chart of color options, check out this internet website: 
% http://xkcd.com/color/rgb/
% 
% SYNTAX 
% RGB = rgb('Color Name') 
% RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N') 
% RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'}) 
% 
% 
% DESCRIPTION 
% RGB = rgb('Color Name') returns the rgb triple of the color described by the
% string 'Color Name'. Try any color name you can think of, it'll probably
% work. 
% 
% RGB = rgb('Color Name 1','Color Name 2',...,'Color Name N') returns an
% N by 3 matrix containing RGB triplets for each color name. 
% 
% RGB = rgb({'Color Name 1','Color Name 2',...,'Color Name N'}) accepts
% list of color names as a character array. 
% 
% 
% EXAMPLE 1
% rgb('baby blue') 
% 
% 
% EXAMPLE 2
% rgb('wintergreen','sunflower yellow','sapphire','radioactive green')
% 
% 
% EXAMPLE 3
% x = -pi:.1:pi;
% y = cos(x);
% plot(x,y,'linewidth',4,'color',rgb('cornflower'))
% hold on
% plot(x,y-1,'*','color',rgb('plum'))
% plot(x,y-2,'linewidth',4,'color',rgb('puke green'))
% legend('cornflower','plum','puke green') 
% set(gca,'color',rgb('azure'))
% text(0,-2,'This text is burnt orange.','fontweight','bold','color',rgb('burnt orange')); 
% 
% 
% AUTHOR INFO
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics.  I do not claim credit for the data
% from the color survey. http://www.chadagreene.com. 
% 
% Updated July 2015 to fix an installation error. Thanks for the tip,
% Florian Klimm! 
% 
% See also ColorSpec, hex2rgb, rgb2hex. 

%% Make sure the function can find the data: 

if exist('xkcd_rgb_data.mat','file')~=2
    disp 'Cannot find xkcd_rgb_data.mat. I will try to install it from rgb.txt now.'
    rgb_install
    disp 'Installation complete.'
end
%% Check inputs: 


if iscellstr(ColorNames)==0 && iscellstr({ColorNames})==1
    ColorNames = {ColorNames}; 
end

if ~isempty(varargin)
    ColorNames = [{ColorNames} varargin];
end

assert(isnumeric(ColorNames)==0,'Input must be color name(s) as string(s).')


%% Search for color, return rgb value: 

% Load data created by rgb_install.m:
load xkcd_rgb_data.mat

% Number of input color names: 
numcolors = length(ColorNames);

% Preallocate a matrix to fill with RGB triplets: 
RGB = NaN(numcolors,3);

% Find rgb triplet for each input color string: 
for k = 1:numcolors
    ColorName = ColorNames{k}; 
    ColorName = strrep(ColorName,'gray','grey'); % because many users spell it 'gray'. 

    % If a color name is not found in the database, display error message
    % and look for near matches: 
    if sum(strcmpi(colorlist,ColorName))==0
        disp(['Color ''',ColorName,''' not found. Consider one of these options:'])
        
        % Special thanks to Cedric Wannaz for writing this bit of code. He came up with a
        % quite clever solution wherein the spectrum of the input color
        % name is compared to the spectra of available options.  So cool. 
        spec = @(name) accumarray(upper(name.')-31, ones(size(name)), [60 1]) ;
        spec_mycol = spec(ColorName); % spectrum of input color name 
        spec_dist = cellfun(@(name) norm(spec(name)-spec_mycol), colorlist);
        [sds,idx]   = sort(spec_dist) ;
        nearbyNames = colorlist(idx(sds<=1.5));
        if isempty(nearbyNames)
            nearbyNames = colorlist(idx(1:3));
        end
        disp(nearbyNames); 
        
        clear RGB
        return % gives up and makes the user try again. 
    end

    RGB(k,:) = rgblist(strcmpi(colorlist,ColorName),:);
end

end

%% Installation subfunction: 

function rgb_install 
if ~exist('rgb.txt','file')
    disp 'Cannot find rgb.txt file. I will try to download it from the internet now.'
    try
    urlwrite('http://xkcd.com/color/rgb.txt','rgb.txt');
    catch 
        disp('Having trouble downloading the data file. You''ll need to download it manually')
        disp('from http://xkcd.com/color/rgb.txt and place it in your current folder.')
        return
    end
end
    
fid = fopen('rgb.txt'); 
RGB = textscan(fid,'%s %s','delimiter','\t');
fclose(fid);

colorlist = RGB{1}; 
hex = RGB{2};

rgblist = newhex2rgb(char(hex));


save('xkcd_rgb_data.mat','colorlist','rgblist')
end

%% newhex2rgb subfunction: 

function [ rgb ] = newhex2rgb(hex,range)
% hex2rgb converts hex color values to rgb arrays on the range 0 to 1. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% SYNTAX:
% rgb = hex2rgb(hex) returns rgb color values in an n x 3 array. Values are
%                    scaled from 0 to 1 by default. 
%                    
% rgb = hex2rgb(hex,256) returns RGB values scaled from 0 to 255. 
% 
% 
% * * * * * * * * * * * * * * * * * * * * 
% EXAMPLES: 
% 
% myrgbvalue = hex2rgb('#334D66')
%    = 0.2000    0.3020    0.4000
% 
% 
% myrgbvalue = hex2rgb('334D66')  % <-the # sign is optional 
%    = 0.2000    0.3020    0.4000
% 
%
% myRGBvalue = hex2rgb('#334D66',256)
%    = 51    77   102
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myrgbvalues = hex2rgb(myhexvalues)
%    =   0.2000    0.3020    0.4000
%        0.5020    0.6000    0.7020
%        0.8000    0.6000    0.2000
%        0.2000    0.2000    0.9020
% 
% 
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myRGBvalues = hex2rgb(myhexvalues,256)
%    =   51    77   102
%       128   153   179
%       204   153    51
%        51    51   230
% 
% HexValsAsACharacterArray = {'#334D66';'#8099B3';'#CC9933';'#3333E6'}; 
% rgbvals = hex2rgb(HexValsAsACharacterArray)
% 
% * * * * * * * * * * * * * * * * * * * * 
% Chad A. Greene, April 2014
%
% Updated August 2014: Functionality remains exactly the same, but it's a
% little more efficient and more robust. Thanks to Stephen Cobeldick for
% the improvement tips. In this update, the documentation now shows that
% the range may be set to 256. This is more intuitive than the previous
% style, which scaled values from 0 to 255 with range set to 255.  Now you
% can enter 256 or 255 for the range, and the answer will be the same--rgb
% values scaled from 0 to 255. Function now also accepts character arrays
% as input. 
% 
% * * * * * * * * * * * * * * * * * * * * 
% See also rgb2hex, dec2hex, hex2num, and ColorSpec. 
% 

%% Input checks:

assert(nargin>0&nargin<3,'hex2rgb function must have one or two inputs.') 

if nargin==2
    assert(isscalar(range)==1,'Range must be a scalar, either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end

%% Tweak inputs if necessary: 

if iscell(hex)
    assert(isvector(hex)==1,'Unexpected dimensions of input hex values.')
    
    % In case cell array elements are separated by a comma instead of a
    % semicolon, reshape hex:
    if isrow(hex)
        hex = hex'; 
    end
    
    % If input is cell, convert to matrix: 
    hex = cell2mat(hex);
end

if strcmpi(hex(1,1),'#')
    hex(:,1) = [];
end

r = hex2dec(hex(:,2:3));
g = hex2dec(hex(:,4:5));
b = hex2dec(hex(:,6:7));

rgb = [r g b]/255; 

end
