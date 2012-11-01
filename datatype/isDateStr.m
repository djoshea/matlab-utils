function [tf fmat num] = isDateStr(s, fmat, varargin)
    % returns true if s is a string representation of a date
    % fmat is an optional format string, if empty detects automatically
    % num is a datenum
    
    allowUnknownFormats = false;
    assignargs(varargin);
    
    if nargin < 2
        fmat = '';
    end

    tf = false;
    num = NaN;

    if isempty(s) || ~ischar(s)
        fmat = '';
        return;
    end
    
    try
        if nargin == 2 && ~isempty(fmat)
            num = datenum(s,fmat);
            tf = true;
        else 
            num = datenum(s);
            fmat = getDateFormat(s);
            tf = true;
            
            % datenum knows more formats than getDateFormat
            % return true only if the format is known or 
            % allowUnknownFormats is true
            if ~allowUnknownFormats && isempty(fmat)
                tf = false;
            end
        end
    catch
        tf = false;
        fmat = '';
        num = NaN;
    end
end

        
