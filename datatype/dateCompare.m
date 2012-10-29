function result = dateCompare(datestr1, datestr2, varargin);
% result = dateCompare(datestr1, datestr2, varargin);
%   optional: 'format' = 'yyyy-mm-dd'
%
%   returns 1 if datestr1 > datestr2, -1 if <, 0 if ==

if isempty(strfind(datestr1, '-'))
    format = 'yyyymmdd';
else
    format = 'yyyy-mm-dd';
end
assignargs(varargin);


dnum1 = datenum(datestr1, format);
dnum2 = datenum(datestr2, format);

result = sign(dnum1-dnum2);

end

