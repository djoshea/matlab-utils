function [tf format num] = isDateStrCell(c, varargin)
% tf = isDataVecCell(c, ['fmat', fmat,] ['allowMultipleFormats', tf])
%   returns true if every element of cell c is a date string (a la isdatevec)
%   or is empty or NaN. if the date format is known, pass it as fmat
%
%   allowMultipleFormats : require all dates match the same format string, if true
%       format will be the format string, if false, format will be a cell array of 
%       format strings for each element 

    fmat = '';
    allowMultipleFormats = false;
    allowUnknownFormats = false; % allow formats recognized by datenum but not by getDateFormat
    assignargs(varargin);

    % ignore empty or nans in the list
    emptyOrNanMask = cellfun(@(x) isempty(x) || (isnumeric(x) && all(isnan(x))), c);

    [tfCell formatCell numCell] = cellfun(@(s) isDateStr(s, fmat, ...
        'allowUnknownFormats', allowUnknownFormats), ...
        c(~emptyOrNanMask), 'UniformOutput', false);
    tf = cell2mat(tfCell);
    num = cell2mat(numCell);

    if allowMultipleFormats
        tf = all(tf);
        format = formatCell;
    else
        format = unique(formatCell);
        tf = all(tf) && numel(unique(formatCell)) == 1;
        if tf
            format = format{1};
        end
    end

end
