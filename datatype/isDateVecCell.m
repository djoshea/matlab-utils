function tf = isDateVecCell(c, varargin)
% tf = isDataVecCell(c, ['fmat', fmat,] ['allowMultipleFormats', tf])
%   returns true if every element of cell c is a date string (a la isdatevec)
%   or is empty or NaN. if the date format is known, pass it as fmat
%   allowMultipleFormats : require all dates match the same format string

fmat = '';
allowMultipleFormats = false;
assignargs(varargin);

    emptyOrNanMask = cellfun(@(x) isempty(x) || (isnumeric(x) && all(isnan(x))), c);

    if allowMultipleFormats
        tf = all(cellfun(@(x) isdatevec(x, fmat), c(~emptyOrNanMask)));
    else
        tf = isdatevec(c(~emptyOrNanMask), fmat);
    end

end
