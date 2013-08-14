function varargout = setdiff(varargin)
%SETDIFF Set difference.
%   C = SETDIFF(A,B) for vectors A and B, returns the values in A that 
%   are not in B with no repetitions. C will be sorted.
%
%   C = SETDIFF(A,B,'rows') for matrices A and B with the same number of
%   columns, returns the rows from A that are not in B. The rows of the
%   matrix C will be in sorted order.
%
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that
%   C = A(IA). If there are repeated values in A that are not in B, then
%   the index of the last occurrence of each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows') also returns an index vector IA such that
%   C = A(IA,:).
%
%   [C,IA] = SETDIFF(A,B,'stable') for arrays A and B, returns the values
%   of C in the order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'sorted') returns the values of C in sorted order.
%   If A is a row vector, then C will be a row vector as well, otherwise C
%   will be a column vector. IA is a column vector. If there are repeated
%   values in A that are not in B, then the index of the first occurrence of
%   each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
%
%   In a future release, the behavior of the following syntaxes will change
%   including:
%     -	occurrence of indices in IA will switch from last to first
%     -	orientation of vector C
%     -	IA will always be a column index vector
%     -	tighter restrictions on combinations of classes
% 
%   In order to see what impact those changes will have on your code, use:
% 
%      [C,IA] = SETDIFF(A,B,'R2012a')
%      [C,IA] = SETDIFF(A,B,'rows','R2012a')
% 
%   If the changes in behavior adversely affect your code, you may preserve
%   the current behavior with:
% 
%      [C,IA] = SETDIFF(A,B,'legacy')
%      [C,IA] = SETDIFF(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%
%      [c1,ia1] = setdiff(a,b)
%      % returns
%      c1 = [2 5 6 7 8 9]
%      ia1 = [20 18 16 13 10 6]
%
%      [c2,ia2] = setdiff(a,b,'stable')
%      % returns
%      c2 = [9 8 7 6 5 2]
%      ia2 = [1 7 11 14 17 20]'
%
%      c = setdiff([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [2 NaN]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER, SORT, SORTROWS.

%   Copyright 1984-2011 The MathWorks, Inc. 
%   $Revision: 1.12.4.12 $  $Date: 2011/11/13 04:02:11 $

% Determine the number of outputs requested.
if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end

narginchk(2,4);
nrhs = nargin;
if nrhs == 2
    [varargout{1:nlhs}] = cellsetdifflegacy(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % setdiff(A,B, ['rows'], ['legacy'/'R2012a']),
    % setdiff(A,B, ['rows'], ['sorted'/'stable']),
    % where the position of 'rows' and 'sorted'/'stable' may be reversed
    nflagvals = 5;
    flagvals = {'rows' 'sorted' 'stable' 'legacy' 'R2012a'};
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,nflagvals);
    for i = 3:nrhs
        flag = varargin{i};
        foundflag = strcmpi(flag,flagvals);
        if ~any(foundflag)
            if ischar(flag)
                error(message('MATLAB:SETDIFF:UnknownFlag',flag));
            else
                error(message('MATLAB:SETDIFF:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:SETDIFF:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:SETDIFF:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:SETDIFF:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:SETDIFF:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:SETDIFF:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:SETDIFF:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = cellsetdiffR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = cellsetdiffR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = cellsetdifflegacy(varargin{1:2},logical(flaginds(1)));
    else % 'legacy' (default behavior)
        [varargout{1:nlhs}] = cellsetdifflegacy(varargin{1:2},logical(flaginds(1)));
    end
end
end

function [c,ia] = cellsetdifflegacy(a,b,isrows)
% 'legacy' flag implementation

% handle inputs
if nargin == 3 && isrows
    warning(message('MATLAB:SETDIFF:RowsFlagIgnored')); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
    error(message('MATLAB:SETDIFF:InputClass',class(a),class(b)))
end

nOut = nargout;

ia = [];

if isempty(a)
    if ~iscell(a)
        c = {};
    else
        c = a;
        ia = zeros(size(a));
    end
    return
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
    ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

% check and set flag if input is a row vector.
if ~iscell(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end

if isempty(b)
    b = {};
elseif ~iscell(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

%Is input a non-column vector?
isrowa = ismatrix(a) && size(a,1)==1 && size(a,2) ~= 1;
%Is input a non-column vector?
isrowb = ismatrix(b) && size(b,1)==1 && size(b,2) ~= 1;

a = a(:);
b = b(:);

if nOut <= 1
    a = unique(a);
else
    [a,ia] = unique(a);
end

if ispc && (length(b) == length(a)) && ~isempty(a) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.  The code
	%reshuffles the data.
	r = [1:3:length(a), 2:3:length(a), 3:3:length(a)]; 
    a = a(r); 
	b = b(r); 
	if nOut > 1
		ia = ia(r);
	end
end
    
[c,ndx] = sort([a;b]);

d = ~strcmp(c(1:end-1),c(2:end));
n = size(a,1);
if length(c) > 1
    d(end + 1,1) = 1;
else if length(c) == 1 
        if n > 0
            ia = 1;
            return 
        end
    end
end
% d = 1 now for any unmatched entry of A or of B.

d = d & (ndx <= n); % Now find only the ones in A.

c = c(d);
if nOut > 1
    ia = ia(ndx(d));
end

if (isrowa || isrowb) && ~isempty(c) || ((isrowa && isrowb) && isempty(c) )
    c = c';
    ia = ia';
end

if (isempty(c) && ambiguous)
    c = reshape(c,0,0);
end
end

function [c,ia] = cellsetdiffR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    order = 'sorted';
else
    if (options(1) > 0)
        warning(message('MATLAB:SETDIFF:RowsFlagIgnored'));
    end
    if options(3) > 0
        order = 'stable';
    else % if options(2) > 0 || sum(options(2:3)) == 0)
        order = 'sorted';
    end
end

% Double empties are accepted and converted to empty cellstrs to maintain
% current behavior.
if isequal(class(a),'double') && isequal(a,zeros(0,0))
    a = {};
end

if isequal(class(b),'double') && isequal(b,zeros(0,0))
    b = {};
end

if ischar(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end

if ischar(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

if ~iscellstr(a) || ~iscellstr(b)
    error(message('MATLAB:SETDIFF:InputClass',class(a),class(b)));
end

% Determine if A is a row vector.
rowvec = isrow(a);

% Convert a and b to columns.
a = a(:);
b = b(:);

% Make sure a and b contain unique elements. Only get indices if needed.
if nargout <= 1
    uA = unique(a,order);
else
    [uA,ia] = unique(a,order);
end
uB = unique(b,'R2012a');
[sortuAuB,indSortuAuB] = sort([uA;uB]);

% d indicates the location of matching entries
d = find(strcmp(sortuAuB(1:end-1),sortuAuB(2:end)));    

indSortuAuB([d;d+1]) = [];              % Remove all matching entries

d = indSortuAuB <= length(uA);          % Values in a that don't match.

if d == 0                   % Force d to be the correct shape when a is 
    d = zeros(0,1);         % cell(0,0) and b is nonempty.
end

% Find c.
if strcmp(order, 'stable') 
    ndx = sort(indSortuAuB(d));   % Sort indSortuAuB(d) for to maintain 'stable' order.
else
    ndx = indSortuAuB(d);
end
c = uA(ndx);

% Find ia.
if nargout > 1
    ia = ia(ndx);
end

if rowvec
    c = c.';
end
end
