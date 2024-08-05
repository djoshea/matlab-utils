function [h, hcbar] = pmatsum(m, varargin)
% visualize a matrix using pcolor

p = inputParser();
p.addParameter("omitmissing", true, @islogical);
p.KeepUnmatched = true;
p.parse(varargin{:});

m = squeeze(m);
if ndims(m) > 2 %#ok<ISMAT>
    if p.Results.omitmissing
        sarg = "omitmissing";
    else
        sarg = "includemissing";
    end
    m = sum(m, 3:ndims(m), sarg);
end

[h, hcbar] = pmat(m, p.Unmatched);