% uicontainer
%  A stub function for calling HG uicontainer()

%   Copyright 2009 The MathWorks, Inc.

function h = uicontainer(varargin)
persistent UseV0CallingNotation

if isempty(UseV0CallingNotation)   
    UseV0CallingNotation = true;
    hTemp = [];
    try
        hTemp = uicontainer('v0', varargin{:});
    catch ME
        UseV0CallingNotation = false;
    end
    if ~isempty(hTemp) && ishandle(hTemp)
        delete(hTemp);
    end
end

if UseV0CallingNotation
    h = uicontainer('v0', varargin{:});
else
    h = uicontainer(varargin{:});
end

