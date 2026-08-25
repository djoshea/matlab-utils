function out = xlim_p(varargin)
%XLIM_P Partial-update wrapper for xlim with optional axes handle.
%   XLIM_P(XL) updates current axes XLim using XL = [LO HI], where NaN
%   entries leave the corresponding current limit unchanged.
%
%   XLIM_P(AX, XL) applies the same behavior to axes AX.
%
%   OUT = XLIM_P(...) returns the resulting limits.

	narginchk(1, 2);

	if nargin == 1
		ax = gca;
		xl = varargin{1};
	else
		ax = varargin{1};
		xl = varargin{2};
	end

	if ~isnumeric(xl) || numel(xl) ~= 2
		error('xlim_p:InvalidLimits', 'Limits must be a numeric 2-element vector [lo hi].');
	end

	xl = reshape(xl, 1, 2);
	cur = xlim(ax);

	if ~isnan(xl(1))
		cur(1) = xl(1);
	end
	if ~isnan(xl(2))
		cur(2) = xl(2);
	end

    xlim(ax, cur);
    out = cur;
end

