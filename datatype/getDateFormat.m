function [format dateNumber] = getDateFormat(str)
    % extracted from datevec.m Mathworks function
    % returns the date format string that matches str 
    % if str is a cellstr, return a cellstr of format strings
    %
    % dateNumber{i} will be the result of calling datenum(str{i}, format{i})
    % both inputs will be cells if str is a cell, otherwise they will be strings

    assert(nargin == 1 && (ischar(str) || iscell(str)), 'Usage: getDateFormat(string)'); 

    % handle cell vs. non-cell inputs gracefully
    if ischar(str)
        strCell = {str};
        stripCell = true;
    else
        strCell = str;
        stripCell = false;
    end

    % format list, add new ones here but update the format masks below as well
    format = '';
    formatstr = cell(11,1);
    formatstr(1) = {'dd-mmm-yyyy HH:MM:SS'};
    formatstr(2) = {'dd-mmm-yyyy'};
    formatstr(3) = {'mm/dd/yy'};
    formatstr(4) = {'mm/dd'};
    formatstr(5) = {'HH:MM:SS'};
    formatstr(6) = {'HH:MM:SS PM'};
    formatstr(7) = {'HH:MM'};
    formatstr(8) = {'HH:MM PM'};
    formatstr(9) = {'mm/dd/yyyy'};
    formatstr(10) = {'dd-mmm-yyyy HH:MM'};  %used by finance
    formatstr(11) = {'dd-mmm-yy'};  %used by finance
    formatstr(12) = {'yyyy-mm-dd'}; % added by @djoshea

    AlphaFormats = [1 1 0 0 0 1 0 1 0 1 1 0];
    %[1 2 6 8 10 11];
    SlashFormats = [ 0 0 1 1 0 0 0 0 1 0 0 0];
    %[3 4 9];
    TwoSlashFormats = [ 0 0 1 0 0 0 0 0 1 0 0 0];
    %[3 9];
    DashFormats = [ 1 1 0 0 0 0 0 0 0 1 1 1];
    %[1 2 10 11];
    ColonFormats = [1 0 0 0 1 1 1 1 0 1 0 0];
    %[1 5 6 7 8 10];
    TwoColonFormats = [1 0 0 0 1 1 0 0 0 0 0 0];
    %[1 5 6];
    SpaceFormats = [1 0 0 0 0 1 0 1 0 1 0 0];
    %[1 6 8 10];

    formatCell = cell(size(strCell));
    for iStr = 1:length(strCell)
        format = '';
        dtnumber = NaN;
        str = strCell{iStr};
        bMask = [ 1 1 1 1 1 1 1 1 1 1 1 1];

        str = strtrim(char(str));
        slashes = strfind(str, '/');
        if ~isempty(slashes)
            bMask = bMask & SlashFormats;
            if (~isempty(slashes) && slashes(1) == 2)
                if (length(slashes) > 1 && slashes(2) == 4)
                    str = ['0' str(1:slashes(1)) '0' str(slashes(1)+1:end)];
                else
                    str = ['0' str];
                end
            elseif (length(slashes) > 1 && slashes(2) - slashes(1) == 2)
                str = [str(1:slashes(1)) '0' str(slashes(1)+1:end)];
            end
            if length(slashes) > 1
                bMask = bMask & TwoSlashFormats;
            else
                bMask = bMask & ~TwoSlashFormats;
            end
        else
            bMask = bMask & ~SlashFormats;
        end

        dashes = strfind(str,'-');
        if ~isempty(dashes)
            bMask = bMask & DashFormats;
            if (~isempty(dashes) && dashes(1) == 2)
                str = ['0' str];
            end
        else
            bMask = bMask & ~DashFormats;   
        end

        colons = strfind(str,':');
        if ~isempty(colons)
            bMask = bMask & ColonFormats;
            if (~isempty(colons)) && (colons(1) == 2) && (length(str) - colons(end) <= 3)
                str = ['0' str];
            end
            if length(colons) > 1
                bMask = bMask & TwoColonFormats;
            else
                bMask = bMask & ~TwoColonFormats;
            end     
        else
            bMask = bMask & ~ColonFormats;
        end      

        spaces = strfind(str,' ');
        if ~isempty(spaces)
            bMask = bMask & SpaceFormats;
        else
            bMask = bMask & ~SpaceFormats;
        end

        for i = 1:length(formatstr)
            if bMask(i)
                try
                    dtnumber = datenum(str, char(formatstr(i)));
                    str1 = dateformverify(dtnumber,char(formatstr(i)), false);
                    if (strcmpi(str, strtrim(str1)) == 1)
                        % found it!
                        format = char(formatstr(i));
                        break;
                    end
                catch exception  %#ok<NASGU>
                    % not found
                end
                if AlphaFormats(i)
                    % attempt with local = true
                    try
                        str1 = dateformverify(dtnumber,char(formatstr(i)),true);
                        if (strcmpi(str, strtrim(str1)) == 1)
                            % found it
                            format = char(formatstr(i));
                            dtnumber = datenum(str, format);
                            break;
                        end
                    catch exception %#ok<NASGU>
                    end
                end
            end
        end

        formatCell{iStr} = format;
        dateNumberCell{iStr} = dtnumber;
    end

    % strip cell if just a cell passed in
    if stripCell
        format = formatCell{1};
        dateNumber = dateNumberCell{1};
    else
        format = formatCell;
        dateNumber = dateNumberCell;
    end
end 

function [S vec]= dateformverify(dtnumber, dateformstr, islocal)
    % stolen from Mathworks internal function

    if isempty(dtnumber)
        S = reshape('', 0, length(dateformstr)); 
        return;
    end

    if ~isfinite(dtnumber)
        %Don't bother to go through mex file, since datestr can not handle
        %non-finite dates.
        error(message('MATLAB:datestr:ConvertDateNumber'));
    end

    try
        % Obtain components using mex file
        [y,mo,d,h,minute,s] = datevecmx(dtnumber,true);  mo(mo==0) = 1;
    catch exception 
        newExc = MException('MATLAB:datestr:ConvertDateNumber',...
            'DATESTR failed converting date number to date vector.');
        newExc = newExc.addCause(exception);
        throw(newExc);
    end

    % format date according to data format template
    S = char(formatdate([y,mo,d,h,minute,s],dateformstr,islocal));
    vec = [y, mo, d, h, minute, s];
end


function [dtstrarray] = formatdate(dtvector,formatstr,islocal)
    %   FORMATDATE casts date vector into a specified date format
    %   [DATESTRING] = FORMATDATE(DATEVECTOR, FORMATSTRING) turns the date
    %   vector into a formated date string, according to the user's date
    %   format template.
    %
    %   INPUT PARAMETERS:
    %   DATEVECTOR: 1 x m double array, containing standard MATLAB date vector.
    %   FORMATSTRING: char string containing a user specified date format
    %                 string. See NOTE 1.
    %
    %   RETURN PARAMETERS:
    %   DATESTRING: char string, containing date and, optionally, time formated
    %               as per user specified format string.
    %
    %   EXAMPLES:
    %   The date vector [2002 10 01 16 8] reformed as a date and time string,
    %   using a user format, 'dd-mm-yyyy HH:MM', will display as 
    %   01-10-2002 16:08 .
    %   
    %   NOTE 1: The format specifier allows free-style date format, within the
    %   following limits - 
    %   ddd  => day is formatted as abbreviated name of weekday
    %   dd   => day is formatted as two digit day of month
    %   d    => day is formatted as first letter of day of month
    %   mmm  => month is formatted as three letter abbreviation of name of month
    %   mm   => month is formatted as two digit month of year
    %   m    => month is formatted as one or two digit month of year
    %   yyyy => year is formatted as four digit year
    %   yy   => year is formatted as two digit year
    %   HH   => hour is formatted as two digit hour of the day
    %   MM   => minute is formatted as two digit minute of the hour
    %   SS   => second is formatted as two digit second of the minute
    %   The user may use any separator and other delimiters of his liking, but
    %   must confine himself to the above format tokens regarding day, month,
    %   year, hour, minute and second.
    % 
    %   
    %------------------------------------------------------------------------------

    % Copyright 2003-2009 The MathWorks, Inc.

    if isempty(dtvector) || isempty(formatstr)
        dtstrarray = '';
        return
    else
        dtstr = formatstr;
    end

    notAMPM = isempty(strfind(formatstr,'AM')) && isempty(strfind(formatstr,'PM'));
    year = []; month = []; day = []; dayOfWeek= []; hour = []; minute = []; second = []; 
    millisecond = [];
    wrtWeekday = 0; wrtday = 0;

    % make sure days are capital D and seconds are capital second, so as not to
    % confuse d for day with d as in %d when building conversion string.
    dtstr = strrep(dtstr,'d','D');
    dtstr = strrep(dtstr,'s','S');
    dtstr = strrep(dtstr,'Y','y');
    dtstr = strrep(dtstr, 'h', 'H');

    if notAMPM
    else
        if islocal
            ampm = getampmtokensmx;
        else
            ampm = {'AM','PM'};
        end
        dtstr = strrep(dtstr,'AM',''); % remove AM to avoid confusion below
        dtstr = strrep(dtstr,'PM',''); % remove PM to avoid confusion below
    end

    %All indices for sorting are computed before modifying the length of the
    %string
    showyr =  strfind(dtstr,'y'); wrtYr =  numel(showyr);
    showmo =  strfind(dtstr,'m'); wrtMo =  numel(showmo);                     
    showhr =  strfind(dtstr,'H'); wrtHr =  numel(showhr);
    showmin = strfind(dtstr,'M'); wrtMin = numel(showmin);
    showsec = strfind(dtstr,'S'); wrtSec = numel(showsec);
    showMsec = strfind(dtstr,'F'); wrtMsec = numel(showMsec);
    showqrt = strfind(dtstr,'Q'); wrtQrt = numel(showqrt);
    [starts, ends] = regexp(dtstr, 'D{1,4}', 'start', 'end');


    %Replace the various day and Weekday formats with the corresponding format
    %specifications.
    dtstr = strrep(dtstr, 'DDDD', '%s');
    dtstr = strrep(dtstr, 'DDD', '%s');
    dtstr = strrep(dtstr, 'DD', '%02d');
    dtstr = strrep(dtstr, 'D', '%s');
    showday = [];
    showWeekDay = [];
    for i = 1: length(starts)
        if ends(i) - starts(i) == 1
            if ~isempty(showday) %Only one numeric day subformat allowed
                error(message('MATLAB:formatdate:dayFormat', formatstr));
            end
            wrtday = 1;
            showday = starts(i);
            day = abs(dtvector(:,3));
        else
            if ~isempty(showWeekDay) %Only one weekday subformat allowed
                error(message('MATLAB:formatdate:dayFormat', formatstr));
            end
            showWeekDay = starts(i);
            wrtWeekday = 1; 
            if islocal
                locale = 'local';
            else
                locale = 'en_us';
            end
            switch  ends(i) - starts(i)
                case 3,
                    %long month names
                    [daynr,dayOfWeek] = weekday(datenum(dtvector), 'long', locale);%#ok
                case {0, 2},
                    [daynr,dayOfWeek] = weekday(datenum(dtvector), locale);%#ok
                    if (ends(i) == starts(i))
                        dayOfWeek = dayOfWeek(:,1);
                    end
            end
        end
    end

    %Calculating year may truncate the first element of the datevector to two
    %digits, thus it must be done after any weekday calculations.
    if wrtYr > 0
        if showyr(end) - showyr(1) >= wrtYr
            error(message('MATLAB:formatdate:yearFormat', formatstr));
        end
        switch wrtYr
            case 4,
                dtstr = strrep(dtstr,'yyyy','%.4d');
            case 2,
                dtstr = strrep(dtstr,'yy','%02d');
                dtvector(:,1) = mod(abs(dtvector(:,1)),100);
            otherwise
                error(message('MATLAB:formatdate:yearFormat', formatstr));
        end
        showyr = showyr(1);
        year = mod(dtvector(:,1),10000); 
    end

    % Format quarter.  Must happen after wrtday and wrtWeekday are set.
    if wrtQrt > 0
        if wrtQrt~= 2 || showqrt(end) - showqrt(1) >= wrtQrt
            error(message('MATLAB:formatdate:quarterFormat', formatstr));
        end
        dtstr = strrep(dtstr,'QQ','Q%1d');
        if wrtMo > 0 || wrtday > 0 || wrtWeekday || wrtHr > 0 || wrtMin > 0 || wrtSec > 0
            error(message('MATLAB:formatdate:quarterFormatMismatch',formatstr));
        end
        showqrt = showqrt(1);
        qrt = floor((dtvector(:,2)-1)/3)+1;
    end
    if wrtMo > 0
        if showmo(end) - showmo(1) >= wrtMo
            error(message('MATLAB:formatdate:monthFormat', formatstr));
        end
        switch wrtMo
            case 4,
                %long month names
                if islocal
                    month = getmonthnamesmx('longloc');
                else
                    month = getmonthnamesmx('long');
                end
                monthfmt = '%s';
                dtstr = strrep(dtstr,'mmmm',monthfmt);
                month = char(month(dtvector(:,2)));
            case 3,
                if islocal
                    month = getmonthnamesmx('shortloc');
                else
                    month = {'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'};
                end
                monthfmt = '%s';
                dtstr = strrep(dtstr,'mmm',monthfmt);
                month = char(month(dtvector(:,2)));
            case 2,
                dtstr = strrep(dtstr,'mm','%02d');
                month = abs(dtvector(:,2));
            case 1,
                if islocal
                    month = getmonthnamesmx('shortloc');
                else
                    month = {'J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D'};
                end
                dtstr = strrep(dtstr,'m','%.1s');
                month = char(month(dtvector(:,2)));
            otherwise
                error(message('MATLAB:formatdate:monthFormat', formatstr));
        end
        showmo = showmo(1);
    end

    % Format time
    if wrtHr > 0
        if wrtHr ~= 2 || showhr(end) - showhr(1) >= wrtHr
            error(message('MATLAB:formatdate:hourFormat', formatstr));
        end
        if notAMPM
            fmt = '%02d';
        else
            fmt = '%2d';
            h = dtvector(:,4);
            c(h<12) = ampm(1);
            c(h>=12) = ampm(2);
            dtvector(:,4) = mod(h-1,12) + 1; % replace hour column with 12h format.
            dtstr = [dtstr '%s']; % append conversion string for AM or PM
        end
        dtstr = strrep(dtstr,'HH',fmt); 
        hour   = dtvector(:,4); 
        showhr = showhr(1);
    end

    if wrtMin > 0
        if wrtMin ~= 2 || showmin(end) - showmin(1) >= wrtMin
            error(message('MATLAB:formatdate:minuteFormat', formatstr));    
        end
        dtstr = strrep(dtstr,'MM','%02d');
        minute = dtvector(:,5); 
        showmin = showmin(1);
    end

    if wrtSec > 0
        if wrtSec ~= 2 || showsec(end) - showsec(1) >= wrtSec
            error(message('MATLAB:formatdate:secondFormat', formatstr));     	
        end	
        dtstr = strrep(dtstr,'SS','%02d');
        second = floor(dtvector(:,6));
        showsec = showsec(1);
    end

    if wrtMsec > 0
        if wrtMsec ~= 3 || showMsec(end) - showMsec(1) >= wrtMsec
            error(message('MATLAB:formatdate:millisecondFormat', formatstr));     	
        end	
        dtstr = strrep(dtstr,'FFF','%03d');
        millisecond = floor(1000*(dtvector(:,6) - floor(dtvector(:,6))));
        showMsec = showMsec(1);
    end
    % build date-time array to print
    if wrtQrt > 0
        dtorder = [showyr, showqrt];    
        dtarray = [{year} {qrt}];
        dtarray = dtarray([(wrtYr>0) (wrtQrt>0)]);
    else
        dtorder = [showyr, showmo, showday, showWeekDay, showhr, showmin, showsec, showMsec];
        dtarray = [{year} {month} {day} {dayOfWeek} {hour} {minute} {second} {millisecond}];
        dtarray = dtarray([(wrtYr>0) (wrtMo>0) (wrtday>0) (wrtWeekday>0) (wrtHr>0) ...
            (wrtMin>0) (wrtSec>0) (wrtMsec>0)]);
    end

    % sort date vector in the order of the time format fields
    [tmp,dtorder] = sort(dtorder);%#ok

    % print date vector using conversion string
    dtarray = dtarray(dtorder);
    rows = size(dtvector,1);
    if (rows == 1)
        %optimize if only one member
        if notAMPM
            dtstrarray = sprintf(dtstr,dtarray{:});
        else
            dtstrarray = sprintf(dtstr,dtarray{:},char(c));
        end
    else
        dtstrarray = cell(rows,1);
        numeldtarray = length(dtarray);
        thisdate = cell(1,numeldtarray);
        for i = 1:rows
            for j = 1:numeldtarray
                % take horzontal slice through cells
                thisdate{j} = dtarray{j}(i,:);
            end
            if notAMPM
                dtstrarray{i} = sprintf(dtstr,thisdate{:});
            else
                dtstrarray{i} = sprintf(dtstr,thisdate{:},char(c{i}));
            end
        end
    end
end
