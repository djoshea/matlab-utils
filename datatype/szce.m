function [szI, szO] = szce(c, dim)
% [szI, szO] = szce(c, [dim])
% size of cell elements
%
% szO is size(c), the outer size. szI is the size of the contents of c, with
% NaN in any dim whose length varies from element to element. Elements with
% fewer dims than the largest are padded with 1s, as size() would.
%
% With no output requested, prints the outer size alongside the size of the
% contents, with a min-max range in place of any dim that varies:
%
%   >> szce(x)
%   4 x 205 { 10 x 11 }
%
%   >> szce(y)
%   4 x 205 { 2-5 x 11 }
%
% If dim is provided, szI is szI(dim) and nothing is printed, so szce(x, 2)
% returns 11 at the prompt. dim may be a vector. Dims beyond the contents'
% ndims are 1, as with size(). For a cell with no elements, szI is [] with no
% dim and NaN with one, since there is nothing to infer the inner size from.
%
% Also works in command syntax, i.e. szce x

    if ischar(c) || (isstring(c) && isscalar(c))
        % called as "szce x", look up x in the caller
        c = evalin('caller', char(c));
    end
    assert(iscell(c), 'szce expects a cell array');

    if nargin < 2
        dim = [];
    elseif ischar(dim) || isstring(dim)
        % called as "szce x 2"
        dim = str2double(dim);
    end

    szOuter = size(c);

    if isempty(c)
        szMin = [];
        szMax = [];
    else
        nd = max(cellfun(@ndims, c(:)));
        szMat = cell2mat(cellfun(@(v) padSize(size(v), nd), c(:), 'UniformOutput', false)); % numel(c) x nd
        szMin = min(szMat, [], 1);
        szMax = max(szMat, [], 1);
    end

    szInner = szMin;
    szInner(szMin ~= szMax) = NaN;

    % szI is deliberately left unassigned on the printing path, so that calling
    % szce(x) at the prompt doesn't also set and echo ans
    if ~isempty(dim)
        assert(all(dim >= 1 & dim == round(dim)), 'dim must be a vector of positive integers');
        if isempty(c)
            szI = nan(size(dim));
        else
            % dims beyond the contents' ndims are 1, as with size()
            szInner(end+1:max(dim)) = 1;
            szI = szInner(dim);
        end
        szO = szOuter;
        return;
    end

    if nargout > 0
        szI = szInner;
        szO = szOuter;
        return;
    end

    if isempty(c)
        strI = '';
    else
        parts = cell(1, numel(szMin));
        for iD = 1:numel(szMin)
            if szMin(iD) == szMax(iD)
                parts{iD} = sprintf('%d', szMin(iD));
            else
                parts{iD} = sprintf('%d-%d', szMin(iD), szMax(iD));
            end
        end
        strI = strjoin(parts, ' x ');
    end

    strO = strjoin(arrayfun(@(s) sprintf('%d', s), szOuter, 'UniformOutput', false), ' x ');
    if isempty(strI)
        fprintf('%s { }\n', strO);
    else
        fprintf('%s { %s }\n', strO, strI);
    end
end

function sz = padSize(sz, nd)
    sz(end+1:nd) = 1;
    sz = reshape(sz, 1, []);
end
