function par = assignargs(varargin)
% par = assignargs(defaults, varargin)
%
%   Like structargs except additionally assigns values individually by their names in
%   caller.
%
%   Overwrites fields in struct defaults with those specified by:
%    - if arg(1) is a structure, the values therein
%    - the values specified in 'name', value pairs in the arguments list
%      (these values take precedence over arg(1)
%   Assigns new values or old defaults in caller workspace
%
% par = structargs(varargin)
%
%   Same functionality as above, except uses all existing variables in the 
%   calling workspace as defaults
%
% Author: Dan O'Shea (dan@djoshea.com), (c) 2008

if nargin == 1
    % called as assignargs(varargin)
    % get the workspace vars here because structargs won't be able to access them
    defaults = [];
    callingWorkspaceVars = setdiff(evalin('caller', 'who'), 'varargin');
    
    for i = 1:length(callingWorkspaceVars)
        defaults.(callingWorkspaceVars{i}) = evalin('caller', callingWorkspaceVars{i});
    end
    args = varargin;
else
    defaults = varargin{1};
    args = varargin(2:end);
end

par = structargs(defaults, args{:});

if isempty(par)
    return;
else
    fields = fieldnames(par);
end
for i = 1:length(fields)
    assignin('caller', fields{i}, par.(fields{i}))
end

end

