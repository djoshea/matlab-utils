function table2rst(t)
%TABLE2RSDT Print table as ReStructured Text 
% table2rst(t) prints the table
% 
% This is a slightly modified version of table/disp() that Mathworks wrote.
% 
% Modified by: Dan O'Shea (2016) djoshea.com

between = 4;
within = 2;
indent = 0;
looseline = '\n';
isLoose = true;
fullChar = true;
[dblFmt,snglFmt] = getFloatFormats();

s = warning('off', 'MATLAB:structOnObject');
t = struct(t);
warning(s);    

varnameFmt = '%s';
    
if (t.nrows > 0) && (t.nvars > 0)
    indentSpaces = repmat(' ', t.nrows, indent);   % indent at left margin
    betweenSpaces = repmat(' ', t.nrows, between); % space betweeen variables
    withinSpaces = repmat(' ', t.nrows, within);   % space between columns within a variable
    if isempty(t.rownames)
        tblChars = indentSpaces;
    else
        rownameChars = char(t.rownames);
        rownameWidth = size(rownameChars,2);
        tblChars = [indentSpaces rownameChars betweenSpaces];
    end
    varnamePads = zeros(1,t.nvars);
    for ivar = 1:t.nvars
        name = t.varnames{ivar};
        var = t.data{ivar};
        
        if ischar(var)
            if ismatrix(var) && (fullChar || (size(var,2) <= 10))
                % Display individual strings for a char variable that is 2D and no
                % more than 10 chars.
                varChars = var;
            else
                % Otherwise, display a description of the chars.
                sz = size(var);
                szStr = ['[1' sprintf('x%d',sz(2:end)) ' char]'];
                varChars = repmat(szStr,sz(1),1);
            end
            
        else
            % Display the individual data if the var is 2D and no more than 3 columns.
            if ~isempty(var) && ismatrix(var) && (size(var,2) <= 3)
                if isnumeric(var) && isempty(enumeration(var))
                    if isa(var,'double')
                        varChars = num2str(var,dblFmt);
                    elseif isa(var,'single')
                        varChars = num2str(var,snglFmt);
                    else % integer types
                        varChars = num2str(var);
                    end
                elseif islogical(var)
                    % Display the logical values using meaningful names.
                    strs = ['false'; 'true '];
                    w1 = size(strs,2); w2 = within;
                    varChars = repmat(' ',size(var,1),(size(var,2)-1)*(w1+w2));
                    for j = 1:size(var,2)
                        varChars(:,(j-1)*(w1+w2)+(1:w1)) = strs(var(:,j)+1,:);
                    end
                 
                % djoshea adding this to remove '' from the strings by
                % converting to categorical and copyign the code from below
                elseif iscellstr(var)
                    var = categorical(var);
                    % Build the output one column at a time, since the char method reshapes
                    % to a single column.
                    varChars = char(zeros(t.nrows,0));
                    for j = 1:size(var,2)
                        if j > 1, varChars = [varChars withinSpaces]; end %#ok<AGROW>
                        varChars = [varChars char(var(:,j))]; %#ok<AGROW>
                    end
                    
                elseif isa(var,'categorical') || isa(var,'datetime') || isa(var,'duration') || isa(var,'calendarDuration')
                    % Build the output one column at a time, since the char method reshapes
                    % to a single column.
                    varChars = char(zeros(t.nrows,0));
                    for j = 1:size(var,2)
                        if j > 1, varChars = [varChars withinSpaces]; end %#ok<AGROW>
                        varChars = [varChars char(var(:,j))]; %#ok<AGROW>
                    end
                elseif iscell(var)
                    % Let the built-in cell display method show the contents
                    % of each cell however it sees fit.  For example, it will
                    % display only a size/type if the contents are large.  It
                    % puts quotes around char contents, which char wouldn't.

                    varStr = evalc('disp(var)');

                    % Work around a special case that the command line needs
                    % but we don't: curly braces around a scalar cell
                    % containing a 0x0
                    if isscalar(var) && max(size(var{1}))==0
                        varStr = removeBraces(varStr);
                    end
                    
                    % varStr is a single row with \n delimiting the chars for
                    % each row of var.  But \n can also be from displaying the
                    % contents of a cell.  There will be an extra trailing \n
                    % if isLoose; that can be left on.
                    loc = [0 find(varStr==10)];
                    [n,m] = size(var); % already checked is 2D
                    if length(loc) == n+1+isLoose % can use them as row delimiters
                        % The cell disp method puts leading whitespace
                        whiteSpace = find(varStr ~= ' ',1,'first') - 1;
                        % Split the \n-delimited string into a char matrix.
                        len = diff(loc) - whiteSpace;
                        varChars = repmat(' ',size(var,1),max(len)-1);
                        for i = 1:n
                            celChars = strtrim(varStr(loc(i)+1:loc(i+1)-1));
                            if ~isempty(celChars) % avoid 0x0 coming from strtrim
                                varChars(i,1:length(celChars)) = celChars;
                            end
                        end
                    else % the display for some cells had a \n in them
                        % Use the built-in to display each cell individually.
                        % This gives a slightly different output than the
                        % above, because cells are not all justified to the
                        % same length.
                        varChars = char(zeros(t.nrows,0));
                        offset = 0;
                        for j = 1:m
                            if j > 1
                                varChars = [varChars withinSpaces]; %#ok<AGROW>
                                offset = size(varChars,2);
                            end
                            for i = 1:n
                                % Display contents of each cell, remove {} around 0x0
                                var_ij = var(i,j);
                                celChars = evalc('disp(var_ij)');
                                if max(size(var_ij{1})) == 0
                                    celChars = removeBraces(celChars);
                                end
                                celChars = strtrim(celChars(1:end-1));
                                if ~isempty(celChars) % avoid 0x0 coming from strtrim
                                    varChars(i,offset+(1:length(celChars))) = celChars;
                                end
                            end
                        end
                    end
                elseif ~isempty(enumeration(var)) % isenumeration(var)
                    varChars = evalc('disp(var)'); %call disp to get the enum display
                    if isLoose % remove trailing \n
                        varChars(end) = [];
                    end
                    numLines = size(var,1);
                    varChars = reshape(varChars,numel(varChars)/numLines,numLines)';
                    %Remove the name padding and trailing \n from enum DISP
                    varChars(:,[1:4 end]) = [];
                else
                    % Display a description of each table element.
                    varChars = getInfoDisplay(var);
                end

            % Either the variable is not 2D, or it's empty, or it's too wide
            % to show. Display a description of each table element.
            else
                varChars = getInfoDisplay(var);
            end
        end
        if size(varChars,2) < length(name)
            varChars(:,end+1:length(name)) = ' ';
        end
        varnamePads(ivar) = size(varChars,2)-length(name);
        
        if ivar == 1 % starting over at left margin
            tblChars = [tblChars varChars]; %#ok<AGROW>
        else
            tblChars = [tblChars betweenSpaces varChars]; %#ok<AGROW>
        end
    end
    
    dispEqStr();
    
    dispVarNames();
    disp(tblChars);
    
    dispEqStr();
else
    str = getString(message('MATLAB:table:uistrings:EmptyTableDisplay',t.nrows,t.nvars,class(t)));
    fprintf('   %s\n',str);
end
fprintf(looseline);

%-----------------------------------------------------------------------
    function dispEqStr()
        if ~isempty(t.rownames)
            eq = repmat('=', 1, rownameWidth);
            spaces = repmat(' ', 1, between);
            fprintf('%s', [eq spaces]);
        end
        
        for ii = 1:t.nvars
            eq = repmat('=',1,length(t.varnames{ii}) + varnamePads(ii));
            spaces = repmat(' ', 1, between);
            fprintf('%s', [eq spaces]);
        end
        fprintf('\n');
    end

    function dispVarNames()
        % @djoshea uncentered the header row
        if ~isempty(t.rownames)
            fprintf('%s', repmat(' ',1,rownameWidth+between));
        end
        ii = 1;
        spaces = repmat(' ',1,varnamePads(ii)+between);
        fprintf(varnameFmt,[t.varnames{ii} spaces]);
        for ii = 2:t.nvars
            spaces = repmat(' ',1,varnamePads(ii)+between);
            fprintf(varnameFmt,[t.varnames{ii} spaces]);
        end
        fprintf('\n');

        if ~isempty(t.rownames)
            fprintf('%s',[repmat('=',1,rownameWidth) repmat(' ', 1, between)]);
        end
        ii = 1;
        ul = repmat('=',1,length(t.varnames{ii})+varnamePads(ii));
        fprintf(varnameFmt,ul);
        for ii = 2:t.nvars
            spaces = repmat(' ',1,between);
            ul = repmat('=',1,length(t.varnames{ii})+varnamePads(ii));
            fprintf('%s',[spaces sprintf(varnameFmt,ul)]);
        end
        fprintf([looseline]);
    end

end % main function

%-----------------------------------------------------------------------
function [dblFmt,snglFmt] = getFloatFormats()
% Display for double/single will follow 'format long/short g/e' or 'format bank'
% from the command window. 'format long/short' (no 'g/e') is not supported
% because it often needs to print a leading scale factor.
switch lower(matlab.internal.display.format)
case {'short' 'shortg' 'shorteng'}
    dblFmt  = '%.5g    ';
    snglFmt = '%.5g    ';
case {'long' 'longg' 'longeng'}
    dblFmt  = '%.15g    ';
    snglFmt = '%.7g    ';
case 'shorte'
    dblFmt  = '%.4e    ';
    snglFmt = '%.4e    ';
case 'longe'
    dblFmt  = '%.14e    ';
    snglFmt = '%.6e    ';
case 'bank'
    dblFmt  = '%.2f    ';
    snglFmt = '%.2f    ';
otherwise % rat, hex, + fall back to shortg
    dblFmt  = '%.5g    ';
    snglFmt = '%.5g    ';
end
end


%-----------------------------------------------------------------------
function str = removeBraces(str)
str = regexprep(str,'\{(.*)\}','$1');
end


%-----------------------------------------------------------------------
function varChars = getInfoDisplay(var)
sz = size(var);
if ismatrix(var)
    szStr = ['[1' sprintf('x%d',sz(2:end))];
else
    szStr = ['[1' sprintf('x%d',sz(2)) sprintf('x%d',sz(3:end))];
end
varChars = repmat([szStr ' ' class(var) ']'],sz(1),1);
end
