% uiflowcontainer
%  A stub function for calling HG uiflowcontainer()

%   Copyright 2009 The MathWorks, Inc.

function h = uiflowcontainer(varargin)
persistent MATLABPre2008b

if isempty(MATLABPre2008b)    
    MATLABPre2008b = verLessThan('matlab', '7.7');
end

if MATLABPre2008b
    h = uiflowcontainer(varargin{:});
else
    h = uiflowcontainer('v0', varargin{:});
end

