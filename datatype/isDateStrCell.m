function [tf format num] = isDateStrCell(c, varargin)
% tf = isDataVecCell(c, ['fmat', fmat,] ['allowMultipleFormats', tf])
%   returns true if every element of cell c is a date string (a la isdatevec)
%   or is empty or NaN. if the date format is known, pass it as fmat
%
%   allowMultipleFormats : require all dates match the same format string, if true
%       format will be the format string, if false, format will be a cell array of 
%       format strings for each element 

    p = inputParser();
    p.addParamValue('fmat', '', @ischar);
    p.addParamValue('allowMultipleFormats', false, @islogical);
    p.addParamValue('allowUnknownFormats', false, @islogical);
    p.parse(varargin{:});
    
    fmat = p.Results.fmat;
    allowMultipleFormats = p.Results.allowMultipleFormats;
    allowUnknownFormats = p.Results.allowUnknownFormats; % allow formats recognized by datenum but not by getDateFormat

    % ignore empty or nans in the list
    emptyOrNanMask = cellfun(@(x) isempty(x) || (isnumeric(x) && all(isnan(x))), c);

    cNotEmpty = c(~emptyOrNanMask);
    tf = true;
    formatCell = cellvec(numel(cNotEmpty));
    num = nan(size(c));
    for i = 1:numel(cNotEmpty)
        [tf, formatCell{i}, num(i)] = isDateStr(cNotEmpty{i}, fmat, ...
            'allowUnknownFormats', allowUnknownFormats);
        if ~tf
            break;
        end
    end
    
    if ~tf
        format = '';
        num = nan(size(c));
        return;
    end
    
   % num = cell2mat(numCell);
    if allowMultipleFormats
        format = formatCell;
    else
        format = unique(formatCell);
        tf =  numel(unique(formatCell)) == 1;
        if tf
            format = format{1};
        end
    end

end
