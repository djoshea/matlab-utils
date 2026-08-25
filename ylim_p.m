function out = ylim_p(varargin)
%YLIM_P Partial-update wrapper for ylim with optional axes handle.
%   YLIM_P(YL) updates current axes YLim using YL = [LO HI], where NaN
%   entries leave the corresponding current limit unchanged.
%
%   YLIM_P(AX, YL) applies the same behavior to axes AX.
%
%   OUT = YLIM_P(...) returns the resulting limits.

	narginchk(1, 2);

	if nargin == 1
		ax = gca;
		yl = varargin{1};
	else
		ax = varargin{1};
		yl = varargin{2};
	end

	if ~isnumeric(yl) || numel(yl) ~= 2
		error('ylim_p:InvalidLimits', 'Limits must be a numeric 2-element vector [lo hi].');
	end

	yl = reshape(yl, 1, 2);
	cur = ylim(ax);

	if ~isnan(yl(1))
		cur(1) = yl(1);
	end
	if ~isnan(yl(2))
		cur(2) = yl(2);
	end

	ylim(ax, cur);
    out = cur;
end

