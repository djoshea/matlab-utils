% showObjectInfo
%  A helper class for gui.autogui and gui.widget 

%   Copyright 2009 The MathWorks, Inc.

classdef showObjectInfo
    
    methods(Static,Access=public)
        
        % generic routine to display properties. 
        % Key difference from default display: 
        % 1) logical values shown as true/false instead of 1 and 0).
        % 2) Property names are linked to relevant help command
        %
        % Sample output:
        %               Value: 'aa'
        %           MenuItems: {4x1 cell}
        %              Enable: false
        %      LabelAlignment: 'left'
        %       LabelLocation: 'above'
        %               Label: 'Algorithm'
        %              Parent: [1x1 gui.autogui]
        %            Position: [1x1 struct]
        %     ValueChangedFcn: []
        %             Visible: true
        %               Units: 'pixels'
        function properties(obj)
            mc = metaclass(obj);
            p = mc.Properties;
            fprintf('<a href="matlab:help %s">%s</a>\n', ...
                    class(obj), class(obj));
            
            propLength = zeros(1,length(p));
            hideProp = false(1,length(p));
            for i=1:length(p)
                hideProp(i) = p{i}.Abstract || p{i}.Hidden || ~strcmp(p{i}.GetAccess,'public');
                propLength(i) = length(p{i}.Name);                    
            end
            numSpaces = 3 + max(propLength(~hideProp));
            fprintf('properties:\n');
            for i=1:length(p)
                if hideProp(i)                   
                    continue;
                end                               
                    
                propname = p{i}.Name;
                propval = obj.(p{i}.Name);
                propclass = class(propval);
                
                spaces = char(' '*ones(1,numSpaces-propLength(i)));
                fprintf('%s<a href="matlab:help %s.%s">%s</a>: ', ...
                    spaces, p{i}.DefiningClass.Name, propname, propname);

                showDefault = true;
                switch propclass
                    case 'double'
                        if isscalar(propval)
                            fprintf('%g\n', propval);
                            showDefault = false;
                        end
                    case 'char'
                        if numel(propval) < 32
                            fprintf('''%s''\n', propval);
                            showDefault = false;
                        end
                    case 'logical'
                        if isscalar(propval)
                            if propval
                                fprintf('true\n');
                            else
                                fprintf('false\n');
                            end
                            showDefault = false;
                        end
                end
                
                if showDefault
                    sz = sprintf('%dx',size(propval));                    
                    if iscell(propval)
                        if isempty(propval)
                            fprintf('{}\n');
                        else
                            fprintf('{%s cell}\n', sz(1:end-1));
                        end
                    else
                        if isempty(propval)
                            fprintf('[]\n');
                        else
                            fprintf('[%s %s]\n', sz(1:end-1), propclass);
                        end
                    end
                end
                
            end

        end        

        % Display the methods on a handle object, leaving out the default
        % implementations. Useful for debugging
        function methods(obj)
            mc = metaclass(obj);
            pp = mc.Methods;
            for i=1:numel(pp)
                if ~strcmp(pp{i}.DefiningClass.Name,'handle')
                    fprintf('%-20s%-20s%-25s\n',pp{i}.Name,pp{i}.Access,pp{i}.DefiningClass.Name);
                end
            end
        end
            
    end
    
end
