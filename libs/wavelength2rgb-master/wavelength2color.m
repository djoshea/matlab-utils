% Function: wavelength2color.m
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 08.07.2020
% Version: 1.0

% Description: converts a wavelength in nm into a color
% input arguments:
%   - maxIntensity: maximum intensity of colorspace
%   - gammaVal 
%   - used colorSpace (either 'rgb', or 'hsv')

% example usage
%  wavelength2color(532, 'gammaVal', 1, 'maxIntensity', 255, 'colorSpace', 'rgb')

% principle stolen from:
%    https://academo.org/demos/wavelength-to-colour-relationship/

function colorCode = wavelength2color(wavelength, varargin)

  % default arguments
  maxIntensity = 1;
  gammaVal = 0.8;
  colorSpace = 'rgb';

  for iargin=1:2:(nargin-1)
    switch varargin{iargin}
      case 'maxIntensity' 
        maxIntensity = varargin{iargin + 1};
      case 'gammaVal'
        gammaVal = varargin{iargin + 1};
      case 'colorSpace'
        switch varargin{iargin + 1}
          case 'rgb'
            colorSpace = 'rgb';
          case 'hsv'
            colorSpace = 'hsv';
          otherwise
            error('Invalid colorspace defined');
        end
      otherwise
        error('Invalid argument passed');
    end
  end

	function outputVal = adjust(inputVal, factor)

		if (inputVal == 0)
	  	outputVal = 0;
	  else
			outputVal = (inputVal * factor)^gammaVal;
	  end

	end

	if (wavelength >= 380) && (wavelength < 440)
		r = -(wavelength - 440) / (440 - 380);
    g = 0;
    b = 1;
	elseif (wavelength >= 440) && (wavelength < 490)
		r = 0;
 		g = (wavelength - 440) / (490 - 440);
    b = 1;
  elseif (wavelength >= 490) && (wavelength < 510)
  	r = 0;
    g = 1;
    b = -(wavelength - 510) / (510 - 490);
  elseif (wavelength >= 510) && (wavelength < 580)
  	r = (wavelength - 510) / (580 - 510);
    g = 1;
    b = 0;
  elseif (wavelength >= 580) && (wavelength < 645)
    r = 1;
    g = -(wavelength - 645) / (645 - 580);
    b = 0;
  elseif (wavelength >= 645) && (wavelength < 780)
    r = 1;
    g = 0;
    b = 0;
  else
  	r = 0;
    g = 0;
    b = 0;
  end
    
  if (wavelength >= 380) && (wavelength < 420)
  	factor = 0.3 + 0.7 * (wavelength - 380) / (420 - 380);
  elseif (wavelength >=  420) && (wavelength < 700)
    factor = 1;
  elseif (wavelength >= 700) && (wavelength < 780)
  	factor = 0.3 + 0.7 * (780 - wavelength) / (780 - 700);
  else
    factor = 0;
  end

  r = adjust(r, factor);
  g = adjust(g, factor);
  b = adjust(b, factor);

  rgbCode = [r, g, b];

  switch colorSpace
    case 'rgb'
      colorCode = rgbCode;
    case 'hsv'
      colorCode = rgb2hsv(rgbCode);
  end

  colorCode = colorCode * maxIntensity;

end