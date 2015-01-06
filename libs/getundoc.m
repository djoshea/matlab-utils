function undocumentedProps = getundoc(arg, skipStandardProps)
%GETUNDOC Get Undocumented Object Properties.
% GETUNDOC('OBJECT') or GETUNDOC(H) returns a structure of
% undocumented properties (names & values) for the object having handle
% H or indentified by the string 'OBJECT'.
%
% GETUNDOC(H,true) returns the undocumented properties of H, while
% skipping the following standard undocumented properties:
%   ALimInclude, ApplicationData, Behavior, CLimInclude, HelpTopicKey, IncludeRenderer,
%   PixelBounds, Serializable, XLimInclude, YLimInclude, ZLimInclude
%
% For example, GETUNDOC('axes') or GETUNDOC(gca) returns undocumented
% property names and values for the axes object.

% Extension of Duane Hanselman's original utility (which is no longer
% available on the File Exchange):
% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-01-06

% Yair Altman
% http://UndocumentedMatlab.com/blog/getundoc

% 2010-03-18: added hidden properties from the classhandle
% 2011-09-11: fix for the upcoming HG2
% 2012-01-16: added public fields (Java & MCOS)
% 2012-04-06: added support for handle() references
% 2012-06-06: added support all the way back to Matlab 6 R12
% 2012-06-21: enabled optional input parameter to skip standard undocumented props
% 2012-12-26: added support for user classes deriving hgsetget
% 2013-02-05: added support for any handle class
% 2013-10-25: added support for any Matlab class object; added onCleanup function

undocumentedProps = [];
if nargin < 1                             % Yair 21/6/2012
    error('Input handle required.')       % Yair 21/6/2012
end
if isempty(arg)                           % Yair 16/1/2012
    return;
elseif ischar(arg) % GETUNDOC('OBJECT')
    switch lower(arg)
        case 'root'                        % root
            h=0;
            hf=0;
        case 'figure'                      % figure
            h=figure('Visible','off');
            hf=h;
        otherwise                          % some other string name of an object
            hf=figure('Visible','off');
            object=str2func(arg);
            try
                h=object('Parent',hf,'Visible','off');
            catch
                error('Unknown Object Type String Provided.')
            end
    end
elseif ishandle(arg) | isa(arg,'timer')   %#ok Yair 16/1/2011, 6/6/2012 - Matlab6
    h=arg;
    hf=0;
elseif isa(arg,'handle') || isobject(arg)  % Yair 26/12/2012 (hgsetget) => 5/2/2013 (handle) => 25/10/2013 (object)
    h=arg;
    hf=0;
else
    try
        h = double(arg);
        if ~ishandle(h), error(' '); end
        hf = 0;
    catch
        error('Unknown Object Handle Provided.')
    end
end

wstate=warning;
try oco = onCleanup(@() onCleanupFcn(wstate)); catch, end   % Yair 25/10/2013: this fails on old Matlab releases, never mind
warning off                                      % supress warnings about obsolete properties
try set(0,'HideUndocumented','off'); catch; end  % Fails in HG2
try
    % get props including undocumented
    undocfnames = fieldnames(get(h));
catch
    % Yair 25/10/2013: probably a class object
    undocfnames = fieldnames(struct(h));
end
try set(0,'HideUndocumented','on'); catch; end   % Fails in HG2
try
    % get the documented props (excluding undocumented)
    docfnames = fieldnames(get(h));
catch
    % Yair 25/10/2013: probably a class object
    docfnames = fieldnames(h);
end

% Yair 18/3/2010 - add a few more undocs:
try
    % This works in HG1
    props = get(classhandle(handle(h)),'properties');
    undocfnames = [undocfnames; get(props(strcmp(get(props,'Visible'),'off')),'Name')];
catch
    % Yair 18/9/2011: In HG2, the above fails, so use the following workaround:
    try
        prop = findprop(handle(h),undocfnames{1});
        props = prop.DefiningClass.PropertyList;
        undocfnames = [undocfnames; {props.Name}'];   % {props([props.Hidden]).Name}
    catch
        % ignore...
    end
end

undocumentedProps = setdiff(undocfnames,docfnames);      % extract undocumented

% Skip some standard undocumented props, if requested - Yair 21/6/2012
if nargin > 1 && skipStandardProps
    undocumentedProps = setdiff(undocumentedProps, {'ALimInclude', 'ApplicationData', 'Behavior', 'CLimInclude', ...
                    'HelpTopicKey', 'IncludeRenderer', 'PixelBounds', ...
                    'Serializable', 'XLimInclude', 'YLimInclude', 'ZLimInclude'});
end

% Get the values in struct format, if relevant
if ~isempty(undocumentedProps)
    try                          % Yair 6/6/2012 - Matlab6
        s = struct(undocumentedProps{1},[]);     % Yair 6/6/2012 - Matlab6
    catch                        % Yair 6/6/2012 - Matlab6
        s = struct([]);          % Yair 6/6/2012 - Matlab6
    end                          % Yair 6/6/2012 - Matlab6
    for fieldIdx = 1 : length(undocumentedProps)
        try
            fieldName = undocumentedProps{fieldIdx};
            %s.(fieldName) = get(h,fieldName);              % Yair 6/6/2012 - Matlab6
            s = setfield(s,fieldName,get(h,fieldName));  %#ok Yair 6/6/2012 - Matlab6
        catch
            %s.(fieldName) = '???';                         % Yair 6/6/2012 - Matlab6
            s = setfield(s,fieldName,'???');             %#ok Yair 6/6/2012 - Matlab6
        end
    end
    undocumentedProps = s;
end

% Yair 16/1/2012: add public fields, if available
try
    s = struct(h);
    sfn = setdiff(fieldnames(s),docfnames);
    for fieldIdx = 1 : length(sfn)
        try
            fieldName = sfn{fieldIdx};
            %value = s.(fieldName);              % Yair 6/6/2012 - Matlab6
            value = getfield(s,fieldName);    %#ok Yair 6/6/2012 - Matlab6
            if isa(value,'java.lang.String')
                value = char(value);
            elseif 0  % better to return the original object reference, not its string representation
                mvalue = char(value);
                classname = class(value);
                if isempty(strfind(mvalue,classname))
                    value = [classname ': ' mvalue];
                end
            end
            %c.(fieldName) = value;              % Yair 6/6/2012 - Matlab6
            undocumentedProps = setfield(undocumentedProps,fieldName,value);  %#ok Yair 6/6/2012 - Matlab6
        catch
            %c.(fieldName) = '???';              % Yair 6/6/2012 - Matlab6
            undocumentedProps = setfield(undocumentedProps,fieldName,'???');  %#ok Yair 6/6/2012 - Matlab6
        end
    end
catch
    % ignore...
end
% Yair end

if hf~=0                     % delete hidden figure holding selected object
    delete(hf)
end
warning(wstate)

% Yair 25/10/2013: onCleanup object used to restore previous warning state,
% even in the case of an error
function onCleanupFcn(wstate)
    warning(wstate)
